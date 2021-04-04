extends Control

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

onready var attack_btn = $AttackBtn

func _ready():
	dungeon_entities.battle_ui = self

func set_weapon_icon(wpn):
	$AttackBtn.icon = wpn.icon


func _on_AttackBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		disable()
		player.attack()

func disable(disable = true):
	print("ll")
	attack_btn.disabled = disable
