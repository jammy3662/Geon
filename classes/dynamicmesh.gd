extends MeshInstance
class_name dynamicmesh

export var texture: Texture
var size = Vector2(1,1)
var basesize = Vector2(256,256)

func _process(delta):
	pass

func resizetexture():
	var mt = self.mesh.material as SpatialMaterial
	var t = mt.albedo_texture
	var img = t.get_data() as Image
	img.resize(256,256,1)
	var txt = ImageTexture.new()
	txt.create_from_image(img)
	txt.storage = 0
	mt.albedo_texture = txt
	self.mesh.material = mt

func tiletexture(s: Vector2):
	var txrsize = self.texture.get_size()
	var factor = txrsize / basesize
	var boundx = s.x * self.scale.x / self.size.x / factor.x
	var boundy = s.y * self.scale.z / self.size.y / factor.y
	var tcountx: float = 1
	var tcounty: float = 1
	if boundx > size.x:
		tcountx = boundx / size.x
	if boundy > size.y:
		tcounty = boundy / size.y
	var mtr = self.mesh.surface_get_material(0) as SpatialMaterial
	mtr.uv1_scale = Vector3(tcountx,tcounty,1)
	self.mesh.material = mtr

func _ready():
	var m = self.mesh.surface_get_material(0) as SpatialMaterial
	m.albedo_color = Color.white
	if m.albedo_texture != null:
		self.texture = m.albedo_texture
	else:
		m.albedo_texture = self.texture
	var pln = self.mesh as PlaneMesh
	resizetexture()
	tiletexture(pln.size)
