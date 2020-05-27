extends RigidBody

var orbdist: Vector3
var orbpt: Vector3
var inputvel = Vector3(0,0,0)
var vel: Vector3
var maxvelh: float = 100
var maxvelv: float = 100

export var speed: float = 30
export var damp: float = 100
export var jumpheight: float = 4

export var useinitial: bool = false
export var initial: float
export var gravity: float
export var fallspeed: float
var fall: float

# the camera
var camera: Camera
var gun: Spatial

var polarity: int = 0
var currentorb: Orb = null

var grounded: bool = false
var paused: bool = false
var pull: bool = false
var gravityaffected: bool = true
var movementenabled: bool = true

var mousey: int

func respawn(point):
	global_transform.origin = point
	grounded = false
	if currentorb != null:
		currentorb.despawn()
		currentorb = null

func _ready():
	get_parent().addplayer(self)
	self.camera = $camera
	self.gun = $camera/gun
	sleeping = true
	contact_monitor = true
	contacts_reported = 1
	$AmbientAudioPlayer.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func contactedorb():
	#print(pull)
	if pull == true:
		pull = false
		gravityaffected = true
		movementenabled = true
		vel = Vector3(0,0,0)
	if currentorb.expired:
		currentorb.despawn()
		currentorb = null
	
func _body_entered(body):
	#print(body.name)
	if body.name == "orb":
		contactedorb()
		pass
	if body.name == "floor":
		grounded = true
	if body.name == "hazard":
		# code for die
		pass

func _body_exited(body):
	if body.name == "floor":
		grounded = false

func createorb():
	var rot = camera.rotation
	var orbscn = load("res://scenes/entities/orb.tscn")
	var orb = orbscn.instance()
	get_parent().add_child(orb)
	currentorb = orb
	var shootpoint = camera.global_transform.origin
	shootpoint -= camera.global_transform.basis.z
	orb.shoot(rot, shootpoint, polarity)

func signalorb():
	if currentorb != null:
		if currentorb.get_parent() == null:
			currentorb = null
	if currentorb == null:
		createorb()
		return
	if currentorb.moving == true:
		#currentorb.stop()
		return
	if currentorb.moving == false:
		if currentorb.active == true:
			var nozzlept = camera.global_transform.origin
			currentorb.recall(nozzlept)
			
func jump():
	fall = jumpheight
	pass

func warp():
	if currentorb != null:
		grounded = false
		currentorb.stop()
		global_transform.origin = currentorb.global_transform.origin
		
func pull():
	if pull == false:
		if currentorb != null:
			if currentorb.shot == true:
				pull = true
				grounded = false
				var orbp = currentorb.global_transform.origin
				self.camera.look_at(orbp, Vector3(0,1,0))
				var zbasis = camera.global_transform.basis.z
				zbasis *= -1
				vel = zbasis
				movementenabled = false
				
func pullupdate():
	if pull == true:
		self.camera.look_at(currentorb.global_transform.origin, Vector3(0,1,0))
		vel = -camera.global_transform.basis.z
		movementenabled = false

func movement():
	if movementenabled:
		inputvel = Vector3(0,0,0)
		if gravityaffected:
			gravity()
		var form = camera.transform.basis
		form.z *= speed / damp
		form.x *= speed / damp
		form.z.y = 0
		form.x.y = 0
		if Input.is_action_pressed("ui_up"):
			inputvel += form.z
		if Input.is_action_pressed("ui_down"):
			inputvel -= form.z
		if Input.is_action_pressed("ui_left"):
			inputvel += form.x
		if Input.is_action_pressed("ui_right"):
			inputvel -= form.x
		if !Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			inputvel.x = 0
			inputvel.z = 0
		

func gravity():
	if grounded == false:
		if fall > -gravity:
			fall -= fallspeed * speed
		if fall < -gravity:
			fall = -gravity
		vel.y = fall / speed
	pass

func controls(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			self.signalorb()
		if event.button_index == 2 and event.pressed:
			self.pull()
	if event is InputEventKey:
		if event.is_action_pressed("ui_a"):
			if grounded == true:
				grounded = false
				jump()
		if event.is_action_pressed("ui_run"):
			if polarity < 2:
				polarity += 1
			else:
				polarity = 0

	if event is InputEventMouseMotion:
		var mousesens: float = 0.008
		# rotate the camera horizontally by the appropriate amount
		camera.rotate_y(mousesens * -event.relative.x)
		# if camera vertical pan speed 'mousey' exceeds max speed, set it back to max speed
		mousey = event.relative.y
		var maxspeed = 22
		mousey = clamp(mousey, -maxspeed, maxspeed)
		# if camera's current vertical rotation after input is between 90 and -90 degrees (directly up and directly down), rotate the camera vertically by the appropriate amount 
		var vro = camera.rotation_degrees.x
		if vro < 83 + (0.008 * -mousey) and mousey < 0:
			camera.rotate_object_local(Vector3(1,0,0), mousesens * -mousey)
		if vro > -83 + (0.008 * -mousey) and mousey > 0:
			camera.rotate_object_local(Vector3(1,0,0), mousesens * -mousey)

func _unhandled_input(event):
	if event is InputEventKey:
		# when pause key is activated
		if event.is_action_pressed("ui_pause"):
			# if the game is not already paused, disable all other keys and pause game, then make mouse cursor visible
			if paused == false:
				paused = true
				movementenabled = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# if the game is paused, capture the mouse cursor and unpause
			else: if paused == true:
				paused = false
				movementenabled = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# ------------------------------
	# if the game is not paused, passes the event to the 'controls' function to be processed
	if paused == false:
		controls(event)

func _integrate_forces(state):
	if currentorb != null:
		pullupdate()
		if currentorb.get_parent() != null:
			currentorb.callpt = global_transform.origin
			orbdist = currentorb.global_transform.origin - global_transform.origin
			for val in [orbdist.x, orbdist.y, orbdist.z]:
				if abs(val) > 100:
					currentorb.despawn()
					currentorb = null
	var netvel = inputvel + vel
	state.linear_velocity = netvel * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement()
	pass

