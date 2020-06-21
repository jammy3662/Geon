extends RigidBody
class_name Player

var lcdat: localdata

# player's input motion
var inputvel = Vector3(0,0,0)
# point of gravity
var gravity = Vector3 (0,-1,0)
# miscellaneous forces
var vel = Vector3(0,0,0)

var lastevent = InputEvent.new()

var inputspeed: float = 14
var maxinspeed: float = 14
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
var carrying: Spatial
var pnlabel: Label
var hud: Control
var pause_menu: Control
var contacting: Array = []

var fr = false
var bc = false
var lf = false
var rt = false

# current polarity:
#  0 = no polarity (gun is off)
#  -1, 1, = negative, positive
var polarity: int = 0
var lastpn: int = 1

var pause: bool = false
var floored: bool = false
var gravity_state: bool = true

# used for mouse tracking
var mousey: int

# Finds first node with matching property.
# 'property' is the name of the property as a string NodePath.
# 'value' is the value to test for.
func find(property: String, value):
	for c in self.get_parent().get_children():
		if c.get(property) == value:
			return c

# Searches through node tree for first instance of node with matching name. Uses match() function to find.			
func findobj(node: String):
	var scn = get_node("/root/lvl_scn")
	for c in scn.get_children():
		print (c.name)
		print (node)
		if c.name.match(node):
			print(c.name)
			return c
		else:
			return null

# Replaces property of named nodes with a given value.
# 'obj' is the name of the node(s)
func replace(obj: String, property: String, value):
	var node = get_node("/root/lvl_scn/"+obj)
	if node.get(property) != null:
		print(node.get(property))
	node.set(property, value)

func pos():
	return self.global_transform.origin

func setpos(p: Vector3):
	self.global_transform.origin = p

func _ready():
	lcdat = $"/root/LocalData"
	camera = $camera
	gun = $camera/gun
	pnlabel = $hud/pn
	hud = $hud
	pause_menu = $pause_menu
	lvl = findobj("lvl")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func updateplayer():
	lcdat.polarity = self.polarity
	lcdat.pos3 = self.pos()
	lcdat.inputvel = self.inputvel
	lcdat.gravity = self.gravity
	lcdat.vel = self.vel
	lcdat.rtn = self.rotation

func pause(p: bool):
	if p: updateplayer()
	if p: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = p
	pause_menu.visible = p
	self.pause = p

func respawn():
	var path = lvl.filename
	lcdat.pos3 = lvl.spawnpt
	var crnt_lvl = findobj("lvl*")
	crnt_lvl.replace_by()
	
func shootorb():
	var basis = camera.global_transform.basis.z
	var geon = load("res://scenes/entities/geon.tscn").instance() as RigidBody
	geon.global_transform.origin = self.pos()
	
func callorb():
	pass

func contactedorb():
	pass
	
func jump():
	if (floored or floored):
		gravity.y = jumppower

func _body_exited(body):
	pass

func _body_entered(body):
	if body.name == "orb":
		contactedorb()
		pass
	if body.name == "hazard":
		respawn()
		pass

func inputvel():
	if !pause:
		if lastevent != null:
			inputvel *= 0
			var form = camera.transform.basis.orthonormalized()
			# adjust vectors to compensate for vertical angle
			form.z.z += -form.y.z
			form.z.x += -form.y.x
			form.x.x += form.x.y
			form.x.z += form.x.y
			# remove vertical component so player cannot 'fly'
			form.z.y = 0
			form.x.y = 0
			# normalize vectors
			form.z = form.z.normalized()
			if self.get("fr") == true:
				inputvel += form.z
			if self.get("bc") == true:
				inputvel += -form.z
			if self.get("lf") == true:
				inputvel += form.x
			if self.get("rt") == true:
				inputvel += -form.x
			inputvel *= inputspeed
			inputvel.x = clamp(inputvel.x, -inputspeed, inputspeed)
			inputvel.y = clamp(inputvel.y, -inputspeed, inputspeed)
			inputvel.z = clamp(inputvel.z, -inputspeed, inputspeed)
		
func gravity():
	if gravity_state == true and !floored:
		if gravity.y > -max_fall_speed:
			gravity.y -= gravityspeed / 10
		gravity.y = clamp(gravity.y, -max_fall_speed, INF)
	
func floorcollision():
	if $floorray.is_colliding():
		self.floored = true
	else:
		self.floored = false
		
func pickobjects():
	var pick = $camera/pickray
	if pick.get_collider() != null:
		var obj = pick.get_collider()
		if obj.name.match("gsphere*"):
			if obj.polarity == self.polarity * -1:
				self.carrying = pick.get_collider()
				
func pnshift():
	if carrying != null:
		self.carrying = null
	polarity *= -1
	lastpn *= -1
	pnlabel.text = "polarity: " + String(polarity)
	pass

func togglegun():
	if carrying != null:
		self.carrying = null
	if self.polarity == 0:
		self.polarity = self.lastpn
	else:
		self.polarity = 0
	pnlabel.text = "polarity: " + String(self.polarity)

func controls(event: InputEvent):
	var dsc = event.as_text()
	self.lastevent = event
	var pressed = event.is_pressed()
	if dsc.match(lcdat.qsv+"*"):
		print("saved")
		updateplayer()
		$hud/saved.visible = true
		lcdat.savegame("user://quicksave")
	if dsc.match(lcdat.qld+"*"):
		print("loaded")
		updateplayer()
		lcdat.loadgame("user://quicksave")
	if dsc == lcdat.fr:
		self.set("fr", pressed)
	if dsc == lcdat.bc:
		self.set("bc", pressed)
	if dsc == lcdat.lf:
		self.set("lf", pressed)
	if dsc == lcdat.rt:
		self.set("rt", pressed)
	if event.is_pressed():
		if dsc.match(lcdat.pr+"*"):
				shootorb()
		if dsc.match(lcdat.sc+"*"):
				pnshift()
		if dsc.match(lcdat.mod+"*"):
				jump()
		if dsc.match("REPLACE WITH VARIABLE FOR RUN TO IMPLEMENT"):
				pass
		if dsc.match(lcdat.pn+"*"):
				togglegun()

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
			#pickarea.rotate_object_local(Vector3(1,0,0), mousesens * mousey)
		if vro > -83 + (0.008 * -mousey) and mousey > 0:
			camera.rotate_object_local(Vector3(1,0,0), mousesens * -mousey)
			#pickarea.rotate_object_local(Vector3(1,0,0), mousesens * mousey)

func _unhandled_input(event):
	if !pause: controls(event)
	if event is InputEventKey:
		if event.is_action_pressed("ui_pause"):
			if !self.pause:
				pause(true)
				pass
			else:
				pause(false)
				pass

func _integrate_forces(state):
	if carrying != null:
		if !carrying.colliding:
			var trans = camera.transform.basis.z * 3
			trans.y *= -1
			carrying.translation = self.pos() + trans
			carrying.translation.y += camera.translation.y
	var stateforce = (inputvel + gravity + vel)
	state.linear_velocity = stateforce
#	if pos().y < lvl.deathplane:
#		respawn()

func _process(delta):
	inputvel()
	gravity()
	floorcollision()
	pickobjects()
	pass

