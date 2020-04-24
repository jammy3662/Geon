extends MeshInstance
class_name GoalMonitor

# must be set or app will crash when monitor is activated!
export var nextscnpath: String = ""
var body: RigidBody

func loadnext(player: Player):
	get_tree().change_scene(nextscnpath)

func activate(player: Player):
	# add code for save game and/or additional menus here
	player.paused = true
	self.loadnext(player)

func _ready():
	self.body = self.get_node("monitor")
	self.body.contact_monitor = true
	self.body.contacts_reported = true
	
func _body_entered(body):
	print(body.collision_mask)
	if body.collision_mask == 1:
		self.activate(body.get_parent())


