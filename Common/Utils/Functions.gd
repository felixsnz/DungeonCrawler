extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if (Input.is_action_just_pressed("Restart")):
		get_tree().reload_current_scene()
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
	pass
