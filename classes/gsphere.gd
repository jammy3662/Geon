extends RigidBody
class_name gsphere

var orbradius: Area
var pradius: Area

var thisradius: Area

func _ready():
	thisradius = $gradius
	pass

func _integrate_forces(state):
	if pradius != null:
		state.transform.origin = pradius.global_transform.origin
	pass

func _area_entered(area):
	print(area.name)
	if area.name == "oradius":
		orbradius = area
	if area.name == "pradius":
		pradius = area


func _area_exited(area):
	pass # Replace with function body.
