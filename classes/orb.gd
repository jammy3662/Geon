extends RigidBody
class_name Orb

var area: Area
var active = false
var moving = false
var shot = false
var expired = false
var speed: float = 60
var damp: float = 100
var callpt: Vector3

var stoppt: Vector3

var vel = Vector3(0,0,0)

var polarity: bool = true

func _integrate_forces(state):
	if moving and expired:
		look_at(callpt, Vector3(0,0,1))
		var dist = callpt - global_transform.origin
		var flatdist = sqrt(pow(dist.x,2) + pow(dist.z,2))
		var updist = sqrt(pow(flatdist, 2) + pow(dist.y, 2))
		var averagedist = (flatdist + updist) / 2
		var zbasis = -speed * global_transform.basis.z * (averagedist / 10)
		vel = zbasis
	var newvel = vel / damp
	state.transform.origin += newvel

func _physics_process(delta):
	if shot == true:
		global_transform.origin = stoppt
		vel = Vector3(0,0,0)

func _ready():
	contact_monitor = true
	contacts_reported = 1
	pass

func _body_entered(body):
	#print(body.name)
	if (body.name != "player" and body.name != "gsurface"):
		despawn()
		pass
	if (body.name == "player" or body.name == "gun") and self.shot == true:
		if self.expired == true:
			despawn()
	if body.name == "gsurface":
		stop()
		
func _body_exited(body):
	pass

func _area_entered(area):
	if area.name == "gradius":
		pass

func shoot(rotation: Vector3, origin: Vector3, pn: bool):
	polarity = pn
	active = true
	moving = true
	global_transform.origin = origin
	self.rotation = rotation
	var zbasis = global_transform.basis.z * speed
	zbasis.y *= -1
	vel = zbasis
	
func recall(endp: Vector3):
	moving = true
	expired = true
	shot = false
	callpt = endp
	look_at(endp, Vector3(0,0,1))
	var xdist = global_transform.origin.x - endp.x
	var ydist = global_transform.origin.y - endp.y
	var zdist = global_transform.origin.z - endp.z
	var flatdist = sqrt(pow(xdist,2) + pow(zdist,2))
	var updist = sqrt(pow(flatdist, 2) + pow(ydist, 2))
	var averagedist = (flatdist + updist) / 2
	var zbasis = -speed * global_transform.basis.z * (averagedist / 10)
	vel = zbasis
	
func stop():
	shot = true
	moving = false
	linear_velocity = Vector3(0,0,0)
	stoppt = global_transform.origin
	
func despawn():
	expired = true
	active = false
	moving = false
	shot = false
	if get_parent() != null:
		get_parent().remove_child(self)
		

