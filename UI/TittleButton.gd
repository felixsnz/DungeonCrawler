extends Button




func _on_New_Game_mouse_entered():
	$AudioStreamPlayer.stream = SelecSound
	$AudioStreamPlayer.play()

func _on_New_Game_button_down():
	$AudioStreamPlayer.stream = ClickSound
	$AudioStreamPlayer.play()


func _on_New_Game_focus_entered():
	$AudioStreamPlayer.stream = SelecSound
	$AudioStreamPlayer.play()
