extends Control

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

onready var attack_btn = $AttackBtn

func _ready():
	dungeon_entities.battle_ui = self
	var player = dungeon_entities.player
	
	player.connect("wpn_changued", self, "_on_player_wpn_changued")
	

func _on_player_wpn_changued(old, new):
	$otherWpn.icon = old.icon
	attack_btn.icon = new.icon
	old.queue_free()
	

func set_weapon_icon(wpn):
	$AttackBtn.icon = wpn.icon

func ask_for_next_level():
	$ConfirmationDialog.popup()

func hide_popup():
	$ConfirmationDialog.hide()


func _on_AttackBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		disable()
		player.attack()

func disable(disable = true):
	attack_btn.disabled = disable


func _on_ConfirmationDialog_confirmed():
	for generator in get_tree().get_nodes_in_group("dungeon_generator"):
		generator.reload_level()


func _on_ChangueWpnBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		player.changue_weapon()
		
