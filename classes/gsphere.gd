extends RigidBody
class_name gsphere

export var polarity: int = 1
var mesh = MeshInstance

func _ready():
	mesh = $mesh
#	mesh.mesh.get("material").duplicate(true)
#	if self.polarity == 1:
#		var ms = mesh.mesh.get("material") as SpatialMaterial
#		var newms = ms.duplicate(true)
#		newms.albedo_color = Color(1,0,0)
#		mesh.set("material", newms)
#	if self.polarity == -1:
#		var ms = mesh.mesh.get("material") as SpatialMaterial
#		var newms = ms.duplicate(true)
#		newms.albedo_color = Color(0,0,1)
#		mesh.set("material", newms)
	pass
