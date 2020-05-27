extends Popup

onready var lcl = $"/root/LocalData"

var sfxvolslider: Slider
var musvolslider: Slider

var sfxvollabel: Label
var musvollabel: Label

var sfxvol: float = 100
var musvol: float = 100

var scanning: bool = false
var scanval: Control
var scanstr: String

func updatesliders():
	self.sfxvol = self.sfxvolslider.value
	self.musvol = self.musvolslider.value
	self.sfxvollabel.text = String(sfxvol)
	self.musvollabel.text = String(musvol)

func ctlstr(s: String):
	if s.match("*BUTTON_RIGHT"):
		return "RMB"
	if s.match("*BUTTON_LEFT"):
		return "LMB"
	if s.match("*BUTTON_MIDDLE"):
		return "MMB"
	if s.match("*BUTTON_WHEEL_UP"):
		return "SCRL_UP"
	if s.match("*BUTTON_WHEEL_DOWN"):
		return "SCRL_DWN"
	#print(s)
	return s

func _ready():
	self.sfxvollabel = $TabContainer/Main/sfxvol/sfxvol_value
	self.musvollabel = $TabContainer/Main/musicvol/musicvol_value
	self.sfxvolslider = get_node("TabContainer/Main/sfxvol")
	self.musvolslider = get_node("TabContainer/Main/musicvol")
	$TabContainer/Main/pr.text = ctlstr(lcl.pr)
	$TabContainer/Main/sc.text = ctlstr(lcl.sc)
	$TabContainer/Main/mod.text = ctlstr(lcl.mod)
	$TabContainer/Main/fr.text = ctlstr(lcl.fr)
	$TabContainer/Main/bc.text = ctlstr(lcl.bc)
	$TabContainer/Main/lf.text = ctlstr(lcl.lf)
	$TabContainer/Main/rt.text = ctlstr(lcl.rt)
	$TabContainer/Main/pn.text = ctlstr(lcl.pn)
	$TabContainer/Main/qsv.text = ctlstr(lcl.qsv)
	$TabContainer/Main/qld.text = ctlstr(lcl.qld)
	updatesliders()
	pass
	
func _input(event):
	if scanning:
		if !(event is InputEventMouseMotion):
			var val = event.as_text()
			var txt = event.as_text()
			if event is InputEventMouseButton:
				var strings = val.split(", pressed", true)
				val = strings[0]
				if event.button_index == 1:
					txt = "LMB"
				if event.button_index == 2:
					txt = "RMB"
				if event.button_index == 3:
					txt = "MMB"
				if event.button_index == 4:
					txt = "SCRL_UP"
				if event.button_index == 5:
					txt = "SCRL_DOWN"
			scanval.text = "<" + String(txt.to_upper()) + ">"
			var prop = scanstr
			print (prop)
			$"/root/LocalData".set(prop, val)
			scanning = false
	
func _process(delta):
	updatesliders()

func popup_hide():
	self.hide()
	pass
	
func resolution_pressed(s: String):
	var coords = Array(s.split("x"))
	var size = Vector2(coords[0],coords[1])
	$"/root/LocalData".rsx = size.x
	$"/root/LocalData".rsy = size.y
	OS.window_size = size

func ctrl_pressed(name: String):
	scanning = true
	scanstr = name
	scanval = get_node("TabContainer/Main/" + name)
	scanval.text = "<***>"

func _save_pressed():
	$"/root/LocalData".savecontrols()
