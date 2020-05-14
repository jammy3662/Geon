extends Node
class_name localdata

var frontkey: InputEvent
var backkey: InputEvent
var leftkey: InputEvent
var rightkey: InputEvent

var frontanalog: InputEvent
var backanalog: InputEvent
var leftanalog: InputEvent
var rightanalog: InputEvent

var primarykey: InputEvent
var secondarykey: InputEvent

var modkey: InputEvent

var music_vol: float = 1
var sfx_vol: float = 1

# player-related variables
var position3d = Vector3(0,0,0)
var polarity: int = 0
var inputvel = Vector3(0,0,0)
var gravity = Vector3(0,-1,0)
var vel = Vector3(0,0,0)
var lvl = "res://scenes/levels/ttrl1"

func loadplayer():
	get_tree().paused = false
	get_tree().change_scene(self.lvl)
	self.connect("scene_loaded", self, "loadplayer2")
func loadplayer2():
	var player = get_tree().current_scene.get_node("player")
	player.pause(false)
	player.polarity = self.polarity
	player.spawnpt = self.position3d
	player.global_transform.origin = self.position3d
	player.inputvel = self.inputvel
	player.gravity = self.gravity
	player.vel = self.vel
	print(self.inputvel, self.gravity, self.vel)

func savegame(path):
	var modpath = path.split("/")
	for n in 3:
		#modpath.remove(0)
		pass
	#var newpath = "user://"
	var newpath = ""
	var index = 0
	for s in modpath:
		index += 1
		if index == modpath.size():
			newpath += s
		else: newpath += s + "/"
	print(newpath)
	var file = File.new()
	file.open(newpath, File.WRITE)
	var data = savedict()
	print(data)
	file.store_line(to_json(data))
	file.close()
	
func loadgame(path: String):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_line())
		music_vol = data["musicvol"]
		sfx_vol = data["sfxvol"]
		position3d.x = data["positionx"]
		position3d.y = data["positiony"]
		position3d.z = data["positionz"]
		polarity = data["polarity"]
		inputvel = Vector3(data["inputvelx"],data["inputvely"],data["inputvelz"])
		gravity = Vector3(data["gravityx"],data["gravityy"],data["gravityz"])
		vel = Vector3(data["velx"],data["vely"],data["velz"])
		lvl = data["lvl"]
		file.close()

func savedict():
	var dictionary = {
		"musicvol" : music_vol,
		"sfxvol" : sfx_vol,
		"positionx" : position3d.x,
		"positiony" : position3d.y,
		"positionz" : position3d.z,
		"polarity" : polarity,
		"inputvelx" : inputvel.x,
		"inputvely" : inputvel.y,
		"inputvelz" : inputvel.z,
		"gravityx" : gravity.x,
		"gravityy" : gravity.y,
		"gravityz" : gravity.z,
		"velx" : vel.x,
		"vely" : vel.y,
		"velz" : vel.z,
		"lvl" : lvl
	}
	return dictionary

func _ready():
	pass
