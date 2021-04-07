extends VBoxContainer




func _on_FullsCheck_button_up():
	OS.set_window_fullscreen(!OS.window_fullscreen)

	


func _on_Back_button_down():
	get_parent().get_parent().hide()
