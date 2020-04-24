extends MeshInstance

func _ready():
	var body = self.get_node("monitor")
	body.contact_monitor = true
	body.contacts_reported = true
