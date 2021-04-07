extends VBoxContainer


	


func _on_Back_button_down():
	get_parent().get_parent().hide()


func _on_FullsCheck_pressed():
	OS.set_window_fullscreen(!OS.window_fullscreen)
