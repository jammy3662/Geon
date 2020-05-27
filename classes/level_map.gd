extends GridMap

var genwalls: bool = false
var walltile: String = "grey_light"
var wallsize: int = 8
var testlength: int = 10
var testcoords = [Vector3(1,0,0),Vector3(-1,0,0),Vector3(0,0,1),Vector3(0,0,-1)]

func generatewallcolumn(c: Vector3):
	var item = self.mesh_library.find_item_by_name("grey_light")
	for n in wallsize:
		if get_cell_item(c.x,c.y+n,c.z) == INVALID_CELL_ITEM:
			set_cell_item(c.x,c.y + n,c.z,item)
	pass

func generatewalls():
	var cells = self.get_used_cells()
	for cell in cells:
		var apt: Vector3
		for c in self.testcoords:
			apt = cell + c
			var acell = get_cell_item(apt.x,apt.y,apt.z)
			if (acell == INVALID_CELL_ITEM): generatewallcolumn(apt)
	pass

func _ready():
	generatewalls()
	var cells = self.get_used_cells()
	for cell in cells:
		var item = get_cell_item(cell.x,cell.y,cell.z)
		if item == mesh_library.find_item_by_name("empty"):
				set_cell_item(cell.x,cell.y,cell.z,INVALID_CELL_ITEM)
	pass
