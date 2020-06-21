extends Label

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_tree().change_scene("res://scenes/entities/lvl_scn.tscn")
