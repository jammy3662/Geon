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

var spawnpt = Vector3(0,0,0)

func storedata():
	pass

func _ready():
	pass
