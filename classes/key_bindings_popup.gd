extends Popup

var sfxvolslider: Slider
var musvolslider: Slider

var sfxvollabel: Label
var musvollabel: Label

var sfxvol: float = 100
var musvol: float = 100

func updatesliders():
	self.sfxvol = self.sfxvolslider.value
	self.musvol = self.musvolslider.value
	self.sfxvollabel.text = String(sfxvol)
	self.musvollabel.text = String(musvol)

func _ready():
	self.sfxvollabel = get_node("TabContainer/Audio/sfxvol/sfxvol_value")
	self.musvollabel = get_node("TabContainer/Audio/musicvol/musicvol_value")
	self.sfxvolslider = get_node("TabContainer/Audio/sfxvol")
	self.musvolslider = get_node("TabContainer/Audio/musicvol")
	updatesliders()
	pass
	
func _process(delta):
	updatesliders()

func popup_hide():
	self.hide()
	pass
