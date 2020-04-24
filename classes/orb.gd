extends Spatial
class_name Orb

var body: RigidBody
var active = false
var moving = false
var shot = false
var expired = false
var speed: float = 30

var polarity: bool = true

func _ready():
	self.body = self.get_node("orb")
	self.body.contact_monitor = true
	self.body.contacts_reported = true
	pass

func _body_entered(body):
	if (body.name != "player" and body.name != "gsurface"):
		self.despawn()
	if (body.name == "player" or body.name == "gun") and self.shot == true:
		self.despawn()
	if body.name == "gsurface":
		self.stop()
		
func _body_exited(body):
	pass

func shoot(rotation: Vector3, origin: Vector3, pn: bool):
	self.body.sleeping = false
	self.polarity = pn
	self.active = true
	self.moving = true
	self.body.global_transform.origin = origin
	self.body.rotation = rotation
	var zbasis = body.global_transform.basis.z * speed
	zbasis.y *= -1
	self.body.linear_velocity = zbasis
	
func recall(endp: Vector3):
	self.body.sleeping = false
	self.moving = true
	body.look_at(endp, Vector3(0,0,1))
	var xdist = body.global_transform.origin.x - endp.x
	var ydist = body.global_transform.origin.y - endp.y
	var zdist = body.global_transform.origin.z - endp.z
	var flatdist = sqrt(pow(xdist,2) + pow(zdist,2))
	var updist = sqrt(pow(flatdist, 2) + pow(ydist, 2))
	var averagedist = (flatdist + updist) / 2
	var zbasis = -speed * body.global_transform.basis.z * (averagedist / 10)
	self.body.linear_velocity = zbasis
	
func stop():
	self.shot = true
	self.moving = false
	self.body.sleeping = true
	self.body.linear_velocity = Vector3(0,0,0)
	
func despawn():
	self.expired = true
	self.active = false
	self.moving = false
	self.shot = false
	if get_parent() != null:
		get_parent().remove_child(self)

func _process(delta):
	pass
