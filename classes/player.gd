extends Spatial
class_name Player

var velx: float = 0
var vely: float = 0
var velz: float = 0

var walkspeed: float = 7
var jumpheight: float = 400

var body: DynamicBody
var camera: Camera
var gun: Spatial

var polarity: bool = true

var currentorb: Orb = null

var jumped: bool = false
var paused: bool = false

var upkey: bool = false
var leftkey: bool = false
var downkey: bool = false
var rightkey: bool = false
var runkey: bool = false
var mousedown: bool = false

var mousey: int

func respawn(point):
	self.body.global_transform.origin = point
	if self.currentorb != null:
		self.currentorb.despawn()
		self.currentorb = null

func _ready():
	get_parent().addplayer(self)
	print("ADVANCED LOGGER brought to you by genericrandom64")
	self.body = self.get_node("player")
	self.body.friction = 0
	self.body.contact_monitor = true
	self.body.contacts_reported = true
	self.camera = self.get_node("player/Camera")
	self.gun = self.get_node("player/Camera/gun")
	get_node("player/AmbientAudioPlayer").play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _body_entered(body):
	if body.name == "orb":
		self.body.gravityaffected = true
	if body.name == "floor":
		jumped = false
	if body.name == "hazard":
		# code for die
		pass

func _body_exited(body):
	if body.name == "floor":
		jumped = true

func createorb():
	var rotation = camera.rotation
	var orbscn = load("res://scenes/entities/orb.tscn")
	var orb = orbscn.instance()
	get_parent().add_child(orb)
	self.currentorb = orb
	var nozzle = self.gun.get_node("orb_nozzle") as MeshInstance
	var shootpoint = camera.global_transform.origin
	shootpoint -= camera.global_transform.basis.z
	orb.shoot(rotation, shootpoint, self.polarity)

func signalorb():
	if self.currentorb != null:
		if self.currentorb.expired == true:
			self.currentorb = null
	if self.currentorb == null:
		createorb()
		return
	if self.currentorb.moving == true:
		#self.currentorb.stop()
		return
	if self.currentorb.moving == false:
		if self.currentorb.active == true:
			var nozzlept = camera.global_transform.origin
			self.currentorb.recall(nozzlept)
		
func warp():
	if self.currentorb != null:
		self.jumped = true
		self.currentorb.stop()
		self.body.global_transform.origin = self.currentorb.body.global_transform.origin
		
func pull():
	if self.currentorb != null:
		if self.currentorb.shot == true:
			self.body.gravityaffected = false
			var orbp = to_local(self.currentorb.body.global_transform.origin)
			var dist = to_local(self.camera.global_transform.origin) - orbp
			var flatdist = sqrt(pow(dist.x,2) + pow(dist.z,2))
			var updist = sqrt(pow(flatdist, 2) + pow(dist.y, 2))
			var averagedist = (flatdist + updist) / 2
			var flatangle = atan(dist.x/dist.z)
			var upangle = asin(updist/flatdist)
			self.camera.rotation.y = flatangle
			self.camera.rotation.x = upangle
			var zbasis = self.camera.global_transform.basis.z * (averagedist / 10)
			

func movement():
	var newspeed: float = walkspeed
	newspeed += 3
#	if runkey == true:
#		newspeed += 5
	var frontx = camera.transform.basis.z.x
	var frontz = camera.transform.basis.z.z
	var leftx = camera.transform.basis.x.x
	var leftz = camera.transform.basis.x.z
	var fronty = camera.transform.basis.z.y
	var finalvector = Vector3(0,0,0)
	if upkey:
		finalvector.x += frontx
		finalvector.z += frontz
	if downkey:
		finalvector.x += -frontx
		finalvector.z += -frontz
	if leftkey:
		finalvector.x += leftx
		finalvector.z += leftz
	if rightkey:
		finalvector.x += -leftx
		finalvector.z += -leftz
	var newvector = Vector3(finalvector.x * newspeed,finalvector.y,finalvector.z * newspeed)
	self.body.linear_velocity = newvector

func controls(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			self.signalorb()
	if event is InputEventKey:
		if event.is_action_pressed("ui_a"):
			if jumped == false:
				jumped = true
				body.jump()
		if event.is_action_pressed("ui_left"):
			self.leftkey = true
		if event.is_action_pressed("ui_right"):
			self.rightkey = true
		if event.is_action_pressed("ui_up"):
			self.upkey = true
		if event.is_action_pressed("ui_down"):
			self.downkey = true
		if event.is_action_released("ui_left"):
			self.leftkey = false
		if event.is_action_released("ui_right"):
			self.rightkey = false
		if event.is_action_released("ui_up"):
			self.upkey = false
		if event.is_action_released("ui_down"):
			self.downkey = false
		if event.is_action_pressed("ui_run"):
			self.runkey = true
			pull()
			
		if event.is_action_released("ui_run"):
			self.runkey = false
	if event is InputEventMouseMotion:
		# rotate the camera horizontally by the appropriate amount
		camera.rotate_y(0.008 * -event.relative.x)
		# if camera vertical pan speed 'mousey' exceeds max speed, set it back to max speed
		mousey = event.relative.y
		var maxspeed = 22
		if mousey > maxspeed: mousey = maxspeed
		if mousey < -maxspeed: mousey = -maxspeed
		# if camera's current vertical rotation after input is between 90 and -90 degrees (directly up and directly down), rotate the camera vertically by the appropriate amount 
		var vro = camera.rotation_degrees.x
		if vro < 83 + (0.008 * -mousey) and mousey < 0:
			camera.rotate_object_local(Vector3(1,0,0), 0.008 * -mousey)
		if vro > -83 + (0.008 * -mousey) and mousey > 0:
			camera.rotate_object_local(Vector3(1,0,0), 0.008 * -mousey)

func _unhandled_input(event):
	# if the primary mouse button is clicked, set the appropriate boolean to true and if false set to false
	if event is InputEventMouseButton and event.is_pressed() == true:
		if event.button_index == 1:
			self.mousedown = true
	if event is InputEventMouseButton and event.is_pressed() == false:
		if event.button_index == 1:
			self.mousedown = false
	# ---------------------------------------------------------------------------------------
	if event is InputEventKey:
		# when pause key is activated
		if event.is_action_pressed("ui_pause"):
			# if the game is not already paused, disable all other keys and pause game, then make mouse cursor visible
			if paused == false:
				paused = true
				for key in [upkey, downkey, leftkey, rightkey]:
					key = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# if the game is paused, capture the mouse cursor and unpause
			else: if paused == true:
				paused = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# ------------------------------
	# if the game is not paused, passes the event to the 'controls' function to be processed
	if paused == false:
		controls(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement()
	pass

