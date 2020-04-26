extends RigidBody
class_name DynamicBody

export var useinitial: bool = false
export var gravityaffected: bool = true
export var initial: float
export var gravity: float
export var fallspeed: float
var fall: float

export var jumpamp: float = 80
var jump: float
var jumping: bool = false

func jump():
	self.fall = jumpamp

func fall():
	if gravityaffected == true:
		if fall > -gravity:
			fall -= fallspeed
		if fall < -gravity:
			fall = -gravity
		self.linear_velocity.y = fall

func jumpmove():
	if jump < jumpamp:
		jump += fallspeed
		self.linear_velocity.y += jump
	if jump > jumpamp or jump == jumpamp:
		jump = jumpamp
		self.jumping = false

func _ready():
	if useinitial == true:
		self.linear_velocity.y = initial
	fall = self.linear_velocity.y
	
func _process(delta):
	fall()
	
