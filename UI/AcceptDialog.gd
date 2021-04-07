extends AcceptDialog


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("popup")
	get_child(1).align = HALIGN_CENTER
#	align = HALIGN_CENTER
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AcceptDialog_popup_hide():
	get_parent().get_node("AcceptDialog2").popup()
	get_parent().get_node("AcceptDialog2").get_child(1).align = HALIGN_CENTER
	
	pass # Replace with function body.
