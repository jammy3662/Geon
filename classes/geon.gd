extends RigidBody



func activate():
	self.collision_layer = 2
	
func deactivate():
	self.collision_layer = 0

func _ready():
	deactivate()
	pass
