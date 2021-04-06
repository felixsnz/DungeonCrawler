extends Control


var notPaused = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if notPaused:
			get_tree().paused = true
			$WindowDialog.popup()
			$bg.show()
			notPaused = false
		else:
			get_tree().paused = false
			$WindowDialog.hide()
			$bg.hide()
			notPaused = true
			


func _on_ResumeBtn_button_down():
	get_tree().paused = false
	$WindowDialog.hide()
	$bg.hide()
	notPaused = true
	pass # Replace with function body.


func _on_SettingsBtn_button_down():
	pass # Replace with function body.


func _on_MainMenuBtn_button_down():
	pass # Replace with function body.


func _on_Close_Game_button_down():
	get_tree().quit()
