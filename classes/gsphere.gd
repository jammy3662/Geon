extends RigidBody
class_name gsphere

export var polarity: int = 1
var mesh = MeshInstance
var colliding: bool = false



func _ready():
	mesh = $mesh
	pass


func _body_entered(body):
	colliding = true
	
func _body_exited(body):
	colliding = false
