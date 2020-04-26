extends RigidBody
class_name Player

var orbdist: Vector3
var orbpt: Vector3
var inputvel = Vector3(0,0,0)
var vel: Vector3
var maxvelh: float = 100
var maxvelv: float = 100

var speed: float = 30
var damp: float = 100
var jumpheight: float = 4

export var useinitial: bool = false
export var initial: float
export var gravity: float
export var fallspeed: float
var fall: float

var camera: Camera
var gun: Spatial

var polarity: bool = true
var currentorb: Orb = null

var jumped: bool = false
var paused: bool = false
var pull: bool = false
var gravityaffected: bool = true
var movementenabled: bool = true

var mousey: int

func angle_and_dist(pt1: Vector3, pt2: Vector3):
	var dist = pt2 - pt1
	var flatdist = sqrt(pow(dist.x,2) + pow(dist.z,2))
	var updist = sqrt(pow(flatdist, 2) + pow(dist.y, 2))
	var averagedist = (flatdist + updist) / 2
	var flatangle = atan(dist.x/dist.z)
	var upangle = atan(dist.y/flatdist)
	return [flatangle, upangle, averagedist]

func respawn(point):
	global_transform.origin = point
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
		jumped = false
	if body.name == "hazard":
		# code for die
		pass

func _body_exited(body):
	if body.name == "floor":
		jumped = true

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
		jumped = true
		currentorb.stop()
		global_transform.origin = currentorb.global_transform.origin
		
func pull():
	if pull == false:
		if currentorb != null:
			if currentorb.shot == true:
				pull = true
				var orbp = currentorb.global_transform.origin
				self.camera.look_at(orbp, Vector3(0,1,0))
				var zbasis = camera.global_transform.basis.z
				zbasis *= -1
				vel = zbasis
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
	if fall > -gravity:
		fall -= fallspeed * speed
	if fall < -gravity:
		fall = -gravity
	#vel.y = -fall
	pass

func controls(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			self.signalorb()
		if event.button_index == 2 and event.pressed:
			self.pull()
	if event is InputEventKey:
		if event.is_action_pressed("ui_a"):
			if jumped == false:
				jumped = true
				jump()
		if event.is_action_pressed("ui_run"):
			if polarity == true:
				polarity = false
			else: 
				polarity = true

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

