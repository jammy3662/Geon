extends Control

func _ready():
	self.hide()
	$load.hide()
	$save.hide()
	pass

func save_file_selected(path):
	$"/root/LocalData".savegame(path)
	pass


func load_file_selected(path):
	$"/root/LocalData".loadgame(path)
	$"/root/LocalData".loadplayer()
	pass

func cancel():
	self.visible = false
	pass

func saveandquit_file_selected(path):
	$"/root/LocalData".savegame(path)
	get_tree().paused = false
	get_tree().change_scene("res://scenes/menus/titlescreen.tscn")
	pass
