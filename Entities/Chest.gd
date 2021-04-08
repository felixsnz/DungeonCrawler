extends StaticBody



var health_pots
var mana_pots
onready var dialog = $AcceptDialog
var can_open = true
var cell_pos

signal actually_ready


# Called when the node enters the scene tree for the first time.
func _ready():
	
	

	$rayfront.force_raycast_update()
	$rayback.force_raycast_update()

	if !$rayback.is_colliding() and !$rayfront.is_colliding():
		rotation_degrees.y = 90
	
	$rayfront.force_raycast_update()
	$rayback.force_raycast_update()
	
	if !$rayback.is_colliding() and !$rayfront.is_colliding():
		queue_free()
	else:
		get_parent().get_parent().chest_pos.append(cell_pos)
		
	
	
	
	health_pots = randi() % 3 + 1
	mana_pots = randi()  % 3 + 1
	
	$AcceptDialog.dialog_text = "\n" + "you found " + str(health_pots) + " health potions and "\
	+ str(mana_pots) + " mana potions!"
	
	$AcceptDialog.get_child(1).align = HALIGN_CENTER


func open():
	if can_open:
		$AudioStreamPlayer.play()
		can_open = false
		dialog.popup_centered()

