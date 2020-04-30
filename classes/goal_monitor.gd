extends RigidBody
class_name GoalMonitor

# must be set or app will crash when monitor is activated!
export var nextscnpath: String = ""

func loadnext(player: Player):
	var scnpath = "res://" + nextscnpath
	get_tree().change_scene(nextscnpath)

func activate(player: Player):
	# add code for save game and/or additional menus here
	player.pause = true
	self.loadnext(player)

func _ready():
	contact_monitor = true
	contacts_reported = 2
	
func _body_entered(body):
	print(body.name)
	if body.name == "player":
		self.activate(body.get_parent())


