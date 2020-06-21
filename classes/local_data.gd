extends Node
class_name localdata

var fr: String = "W"
var bc: String = "S"
var lf: String = "A"
var rt: String = "D"

var pr: String = "InputEventMouseButton : button_index=BUTTON_LEFT"
var sc: String = "InputEventMouseButton : button_index=BUTTON_RIGHT"

var mod: String = "Space"
var pn: String = "E"

var qsv: String = "0"
var qld: String = "9"

var mus_vol: float = 1
var sfx_vol: float = 1

var rsx = 1280
var rsy = 720

# player-related variables
var pos3 = Vector3(0,0,0)
var rtn = Vector3(0,0,0)
var polarity: int = 0
var inputvel = Vector3(0,0,0)
var gravity = Vector3(0,-1,0)
var vel = Vector3(0,0,0)
var lvl = "res://scenes/levels/ttrl1"

func loadplayer():
	get_tree().paused = false
	var player = get_node("*/player")
	yield()
	player.pause(false)
	player.polarity = self.polarity
	player.spawnpt = self.position3d
	player.setpos(self.position3d)
	player.inputvel = self.inputvel
	player.gravity = self.gravity
	player.vel = self.vel
	player.rotation = self.rtn

func savegame(path):
	var modpath = path.split("/")
	var newpath = ""
	var index = 0
	for s in modpath:
		index += 1
		if index == modpath.size():
			newpath += s
		else: newpath += s + "/"
	var file = File.new()
	file.open(newpath, File.WRITE)
	var data = savedict()
	file.store_line(to_json(data))
	file.close()
	
func loadgame(path: String):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_line())
		pos3.x = data["positionx"]
		pos3.y = data["positiony"]
		pos3.z = data["positionz"]
		polarity = data["polarity"]
		inputvel = Vector3(data["inputvelx"],data["inputvely"],data["inputvelz"])
		gravity = Vector3(data["gravityx"],data["gravityy"],data["gravityz"])
		vel = Vector3(data["velx"],data["vely"],data["velz"])
		lvl = data["lvl"]
		file.close()

func savecontrols():
	var file = File.new()
	file.open("user://config", File.WRITE)
	var data = {
		"fr": fr,
		"bc": bc,
		"lf": lf,
		"rt": rt,
		"mod": mod,
		"pn": pn,
		"pr": pr,
		"sc": sc,
		"qsv": qsv,
		"qld": qld,
		"mus_vol": mus_vol,
		"sfx_vol": sfx_vol,
		"rsx": rsx,
		"rsy": rsy
	}
	file.store_line(to_json(data))
	
func loadcontrols():
	var file = File.new()
	if file.file_exists("user://config"):
		file.open("user://config", File.READ)
		var data = parse_json(file.get_line())
		for key in data.keys():
			var idx = data.keys().find(key)
			var val = data.values()[idx]
			var st = String(key)
			self.set(st, val)
		file.close()

func savedict():
	var dictionary = {
		"positionx" : pos3.x,
		"positiony" : pos3.y,
		"positionz" : pos3.z,
		"rtx" : rtn.x,
		"rty" : rtn.y,
		"rtz" : rtn.z,
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
	self.loadcontrols()
