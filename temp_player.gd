extends RigidBody
class_name temp_player

# variables to track the orb
var orbdist: Vector3
var orbpt: Vector3

# player's input motion
var inputvel = Vector3(0,0,0)
# point of gravity
var gravity = Vector3 (0,-1,0)
# miscellaneous forces
var vel = Vector3(0,0,0)

export var inputspeed: float = 1
export var gravityspeed: float = 1
export var miscspeed: float = 1
export var netspeed: float = 1
var jumppower: float = 20
var spawnpt: Vector3

# local nodes
var lvl: Level
var camera: Camera
var gun: Spatial
var orb: Orb

# current polarity:
#  0 = no polarity (gun is off)
#  -1, 1, = negative, positive
var polarity: int = 0

var pause: bool = false
var floored: bool = false
var gravity_state: bool = true

# used for mouse tracking
var mousey: int

func _ready():
	self.lvl = get_parent() as Level
	get_parent().addplayer(self)
	self.spawnpt = Vector3(lvl.spawnx, lvl.spawny, lvl.spawnz)
	self.camera = $camera
	self.gun = $camera/gun
	self.orb = load("res://scenes/entities/orb.tscn").instance()
	contact_monitor = true
	contacts_reported = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func respawn(point):
	global_transform.origin = spawnpt
	floored = false
	
func shootorb():
	
	var basis = camera.global_transform.basis.z
	var pt = -basis.normalized() * orb.transform.origin
	var dir = pt - to_global(orb.global_transform.origin)
	orb.shoot(dir, polarity)
	
func callorb():
	pass

func contactedorb():
	pass
	
func jump():
	gravity.y += jumppower * gravityspeed
	
func pnshift():
	if polarity < 1:
		polarity += 1
	else:
		polarity = -1
	pass

func _body_entered(body):
	#print(body.name)
	if body.name == "orb":
		contactedorb()
		pass
	if body.name == "floor":
		floored = true
	if body.name == "hazard":
		respawn(Vector3(0,2,0))
		pass

func _body_exited(body):
	if body.name == "floor":
		floored = false

func inputvel():
	if !pause:
		inputvel = Vector3(0,0,0)
		var form = camera.transform.basis.orthonormalized()
		form.z.y *= 0
		form.x.y *= 0
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
		inputvel *= inputspeed
		
func gravityvel():
	if gravity_state == true:
		if !floored:
			gravity.y = -1 * gravityspeed
		else:
			gravity.y = 0
			
func miscvel():
	var newvel = vel.normalized()
	vel = newvel * miscspeed

func controls(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			shootorb()
			pass
		if event.button_index == 2 and event.pressed:
			callorb()
			pass
	if event is InputEventKey:
		if event.is_action_pressed("ui_a"):
			jump()
		if event.is_action_pressed("ui_run"):
			pnshift()

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
	if !pause: controls(event)
	if event is InputEventKey:
		if event.is_action_pressed("ui_pause"):
			if !pause:
				pause = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				pause = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _integrate_forces(state):
	var netvel = inputvel + gravity + vel
	state.linear_velocity = netvel * netspeed

func _process(delta):
	inputvel()
	gravityvel()
	miscvel()
	pass

