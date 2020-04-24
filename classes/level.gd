extends Spatial
class_name Level

export var spawnx: float = 0
export var spawny: float = 0
export var spawnz: float = 0

export var deathplane: float = 0
var player: Player

func addplayer(player: Player):
	self.player = player

func _ready():
	pass

func _process(delta):
	if self.player != null:
		if player.body.global_transform.origin.y < deathplane:
			player.respawn(Vector3(spawnx,spawny,spawnz))
