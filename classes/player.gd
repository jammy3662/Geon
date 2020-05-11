extends RigidBody
class_name Player

var local_data: localdata

# variables to track the orb
var orbdist: Vector3
var orbpt: Vector3
var current_global_position: Vector3
var global_position_delta: Vector3
var body_bottom: Vector3
# player's input motion
var inputvel = Vector3(0,0,0)
# point of gravity
var gravity = Vector3 (0,-1,0)
# miscellaneous forces
var vel = Vector3(0,0,0)

var inputspeed: float = 14
var gravityspeed: float = 13
var miscspeed: float = 1
var netspeed: float = 1
var max_fall_speed: float = 80
var jumppower: float = 20
var spawnpt: Vector3

# local nodes
var lvl: Level
var camera: Camera
var gun: Spatial
var orb: Orb
var carrying: Spatial
var pickarea: Area
var pnlabel: Label
var contacting: Array = []

# current polarity:
#  0 = no polarity (gun is off)
#  -1, 1, = negative, positive
var polarity: int = 0
var pndir: int = 1

var pause: bool = false
var floored: bool = false
var gravity_state: bool = true

# used for mouse tracking
var mousey: int

func _ready():
	local_data = get_node("/root/LocalData")
	self.lvl = get_parent() as Level
	self.spawnpt = Vector3(lvl.spawnx, lvl.spawny, lvl.spawnz)
	local_data.spawnpt = spawnpt
	current_global_position = global_transform.origin
	self.camera = $camera
	self.gun = $camera/gun
	self.orb = load("res://scenes/entities/orb.tscn").instance()
	self.pickarea = $pickarea
	self.pnlabel = $hud/pn
	var pt = self.global_transform.origin
	pt.y -= scale.y / 2
	body_bottom = pt
	contact_monitor = true
	contacts_reported = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func reparent(node: Node, new: Node):
	var par = node.get_parent()
	par.remove_child(node)
	new.add_child(node)

func respawn():
	var path = lvl.filename
	get_tree().change_scene(path)
	
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
	if (floored or floored):
		gravity.y = jumppower
	
func pnshift():
	if carrying != null:
		var b = carrying
		call("_body_exited", b)
		self.carrying = null
	polarity += pndir
	if polarity != 0:
		pndir *= -1
	pnlabel.text = "polarity: " + String(polarity)
	#print("gun polarity: ", self.polarity)
	pass

func _body_exited(body):
	#contacting.remove(contacting.find(body))
	if body.name == "floor" or body.name.match("gplate*"):
		floored = false

func _body_entered(body):
	#contacting.append(body)
	if body.name.match("gsphere*"):
		var sp = body as gsphere
		if sp.polarity == -self.polarity:
			carrying = sp
	if body.name == "orb":
		contactedorb()
		pass
	if body.name.match("floor*") or body.name.match("gplate*"):
		floored = true
	if body.name == "hazard":
		respawn()
		pass

func inputvel():
	if !pause:
		inputvel = Vector3(0,0,0)
		var form = camera.transform.basis
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
		inputvel *= inputspeed
		if !Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			inputvel.x = 0
			inputvel.z = 0
			
func gravity():
	if gravity_state == true:
		if gravity.y > -max_fall_speed:
			gravity.y -= gravityspeed / 10
		gravity.y = clamp(gravity.y, -max_fall_speed, INF)
	

func controls(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			shootorb()
			pass
		if event.button_index == 2 and event.pressed:
			pnshift()
			pass
	if event is InputEventKey:
		if event.is_action_pressed("ui_a"):
			jump()
		if event.is_action_pressed("ui_run"):
			pass

	if event is InputEventMouseMotion:
		var mousesens: float = 0.008
		# rotate the camera horizontally by the appropriate amount
		camera.rotate_y(mousesens * -event.relative.x)
		pickarea.rotate_y(mousesens * -event.relative.x)
		# if camera vertical pan speed 'mousey' exceeds max speed, set it back to max speed
		mousey = event.relative.y
		var maxspeed = 22
		mousey = clamp(mousey, -maxspeed, maxspeed)
		# if camera's current vertical rotation after input is between 90 and -90 degrees (directly up and directly down), rotate the camera vertically by the appropriate amount 
		var vro = camera.rotation_degrees.x
		if vro < 83 + (0.008 * -mousey) and mousey < 0:
			camera.rotate_object_local(Vector3(1,0,0), mousesens * -mousey)
			#pickarea.rotate_object_local(Vector3(1,0,0), mousesens * mousey)
		if vro > -83 + (0.008 * -mousey) and mousey > 0:
			camera.rotate_object_local(Vector3(1,0,0), mousesens * -mousey)
			#pickarea.rotate_object_local(Vector3(1,0,0), mousesens * mousey)

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
	if carrying != null:
		var trans = camera.transform.basis.z
		trans.y *= -1
		carrying.translation = self.transform.origin + trans * 3
		carrying.translation.y += camera.translation.y
	global_position_delta = state.transform.origin - current_global_position
	current_global_position = state.transform.origin
	body_bottom = Vector3(self.global_transform.origin.z, self.global_transform.origin.y - self.scale.y / 2, self.global_transform.origin.z)
	state.linear_velocity = inputvel + + gravity + vel
	if current_global_position.y < lvl.deathplane:
		respawn()

func _process(delta):
	inputvel()
	gravity()
	pass

