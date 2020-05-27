extends Node2D

func _ready():
	var lcl = $"/root/LocalData"
	lcl.loadcontrols()
	OS.window_size = Vector2(lcl.rsx,lcl.rsy)
	pass
