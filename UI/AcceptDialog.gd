extends Control

func _ready():
	$Moving.call_deferred("popup_centered")
	$Moving.get_child(1).align = HALIGN_CENTER

func _on_Moving_about_to_show():
	Global.actual_dialog = $Moving
	pass # Replace with function body.

func _on_Moving_popup_hide():
	$Rotating.popup_centered()
	$Rotating.get_child(1).align = HALIGN_CENTER

func _on_Rotating_about_to_show():
	Global.actual_dialog = $Rotating


func _on_Rotating_popup_hide():
	self.queue_free()
