extends KinematicBody
class_name Door

var tween: Tween

export var id: int = 1
export var dir = Vector3(0,0,0)
var power: int = 0
export var count: int = 1
var path: String
var on: bool = false
# stages
#  0 = off
#  1 = moving
#  2 = on
var stage: int = 0

func pos():
	return self.global_transform.origin
	
func setpos(p: Vector3):
	self.global_transform.origin = p

func on():
	on = true
	path = String(self.get_path()) + ":translation"
	tween.interpolate_property(self, NodePath(path), null, (pos() + dir), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)

func off():
	on = false
	path = String(self.get_path()) + ":translation"
	tween.interpolate_property(self, NodePath(path), null, (pos() - dir), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)

func toggle():
	if on:
		off()
	else:
		on()
	
func update(n: int):
	power += n
	if power >= count:
		on()
		print("activated")
	if power < count and on == true:
		off()
		print("deactivated")

func _ready():
	path = String(self.get_path()) + ":translation"
	print(path)
	tween = $Tween
	pass

func _process(delta):
	pass
