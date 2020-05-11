extends Control

var player: Player

func _ready():
	player = self.get_parent() as Player
	
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_pause"):
			get_tree().paused = false
			pass
	pass

func quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/menus/titlescreen.tscn")


func quit_cancel_pressed():
	$panel/menu/confirm_panel.hide()

func menu_pressed():
	$panel/menu/confirm_panel.show()

func options_pressed():
	$options_menu.visible = true

func continue_pressed():
	player.pause(false)
