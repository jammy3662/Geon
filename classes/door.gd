extends KinematicBody
class_name Door

var animator: AnimationPlayer

export var id: int = 1
export var dir = Vector3(0,0,0)
var power: int = 0
export var count: int = 1
var on: bool = false
# stages
#  0 = off
#  1 = moving
#  2 = on
var stage: int = 0

func on():
	on = true
	animator.play("move")

func off():
	on = false
	animator.play_backwards("move")

func toggle():
	if on:
		off()
	else:
		on()
		
func setupanimation():
	var ani = Animation.new()
	var track = ani.add_track(Animation.TYPE_TRANSFORM)
	var prpath = String(self.get_path()) + ":translation"
	ani.track_set_path(track, prpath)
	print(self.translation, dir, self.translation + dir)
	ani.track_insert_key(track, 0, self.translation)
	ani.track_insert_key(track, 1, self.translation + dir)
	animator.add_animation("move", ani)
	
func update(n: int):
	power += n
	if power >= count:
		on()
	if power < count and on == true:
		off()
	print(on)

func _ready():
	animator = $AnimationPlayer
	setupanimation()
	pass

func _process(delta):
	#print(self.translation)
	pass
