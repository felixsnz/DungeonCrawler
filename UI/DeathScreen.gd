extends WindowDialog

const game = "res://Game.tscn"
var menu = load("res://UI/TittleScreen.tscn")

var hide_from_out_click = true

func _on_PlayAgain_button_down():
	hide_from_out_click = false
	var err = get_tree().change_scene(game)
	print("from play again:", err)

func _on_MainMenu_button_down():
	hide_from_out_click = false
# warning-ignore:return_value_discarded
	Global.player.camera.current = false
	var err = get_tree().change_scene_to(menu)
	print("from play again:", err)

func _on_CloseGame_button_down():
	hide_from_out_click = false
	get_tree().quit()

func _on_DeathScreen_popup_hide():
	if hide_from_out_click:
		popup()

func _on_DeathScreen_about_to_show():
	$Label.text = "You Reached floor " + str(Global._floor)
