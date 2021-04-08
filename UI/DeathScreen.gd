extends WindowDialog


const game = "res://Game.tscn"
const main_menu = "res://UI/TittleScreen.tscn"

var hide_from_out_click = true


func _ready():
	pass # Replace with function body.




func _on_PlayAgain_button_down():
	hide_from_out_click = false
	get_tree().change_scene(game)


func _on_MainMenu_button_down():
	hide_from_out_click = false
	get_tree().change_scene(main_menu)


func _on_CloseGame_button_down():
	hide_from_out_click = false
	get_tree().quit()


func _on_DeathScreen_popup_hide():
	if hide_from_out_click:
		popup()



func _on_DeathScreen_about_to_show():
	$Label.text = "You Reached floor " + str(Global._floor)
	Global._floor = 0
