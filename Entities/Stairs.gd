extends StaticBody


var can_reload_level = true
var can_popup = true


func show_next_lvl_dialog():
	if can_popup:
		$ConfirmationDialog.popup_centered()

func _on_ConfirmationDialog_confirmed():
	if can_reload_level:
		can_reload_level = false
		$ConfirmationDialog/confirm.play()
		var dungeon_gen = get_tree().current_scene.get_node("DungeonGen")
		dungeon_gen.reload_level()


func _on_ConfirmationDialog_popup_hide():
	can_popup = true
	$ConfirmationDialog/cancel.play()


func _on_ConfirmationDialog_about_to_show():
	can_popup = false
