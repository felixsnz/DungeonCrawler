extends Control


var notPaused = true
var menu = load("res://UI/TittleScreen.tscn")

func _ready():
	show()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	$WindowDialog/Options.popup_centered()
#	$WindowDialog/Options.
	pass # Replace with function body.


func _on_MainMenuBtn_button_down():
# warning-ignore:return_value_discarded
	Global.player.camera.current = false
	var err = get_tree().change_scene_to(menu)
	print("from pause main menu: ", err)


func _on_Close_Game_button_down():
	get_tree().quit()


func _on_WindowDialog_popup_hide():
	get_tree().paused = false
	$WindowDialog.hide()
	$bg.hide()
	notPaused = true
	pass # Replace with function body.
