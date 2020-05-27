extends RigidBody
class_name gplate

export var doorid: int = 0
export var polarity: int = 1

func _ready():
	pass

func _body_entered(body):
	if body.name.match("gsphere*"):
		var sp = body as gsphere
		if sp.polarity == -self.polarity:
			var scn = get_tree().current_scene
			for node in scn.get_children():
				if node is Door:
					print(node)
					var door = node as Door
					print(door.id, " ",self.doorid)
					if door.id == doorid:
						door.update(1)
	pass

func _body_exited(body):
	if body.name.match("gsphere*"):
		var sp = body as gsphere
		if sp.polarity == -self.polarity:
			var scn = get_tree().current_scene
			for node in scn.get_children():
				if node is Door:
					print(node)
					var door = node as Door
					print(door.id, " ",self.doorid)
					if door.id == doorid:
						door.update(-1)
	pass
