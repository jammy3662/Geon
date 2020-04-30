extends RigidBody
class_name Orb

var area: Area
# the stage of the orb's life
#  0 = inactive
#  1 = shot
#  2 = stopped
#  3 = called
var stage: int = 0
var speed: float = 60
var damp: float = 0

export var spawnpt: Vector3
var vel = Vector3.ZERO

var polarity: int = 0

func _integrate_forces(state):
	var newvel = vel - Vector3(damp,damp,damp)
	state.transform.origin += newvel

func _physics_process(delta):
	if stage == 2:
		vel = Vector3(0,0,0)

func _ready():
	contact_monitor = true
	contacts_reported = 1
	reset(spawnpt)
	pass

func _body_entered(body):
	#print(body.name)
	if (body.name != "player" and body.name != "gsurface"):
		reset(spawnpt)
		pass
	if (body.name == "player" or body.name == "gun") and stage == 3:
		reset(spawnpt)
	if body.name == "gsurface":
		stop()
		
func _body_exited(body):
	pass

func _area_entered(area):
	if area.name == "gradius":
		pass

func shoot(direction: Vector3, pn: int):
	stage = 1
	polarity = pn
	visible = true
	transform.origin = spawnpt
	var dir = direction.normalized() * speed
	dir.y *= -1
	vel += dir
	
func stop():
	stage = 2
	vel = Vector3.ZERO
	
func recall(endp: Vector3):
	stage = 3
	var dir = transform.origin.distance_to(spawnpt)
	dir.y *= -1
	vel = dir
	
func reset(pt: Vector3):
	stage = 0
	visible = false
	spawnpt = pt
	transform.origin = spawnpt
