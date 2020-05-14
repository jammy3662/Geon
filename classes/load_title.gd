extends Label

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			$save_load/load.popup_centered()
