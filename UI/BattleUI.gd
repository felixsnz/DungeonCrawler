extends Control

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

onready var attack_btn = $AttackBtn
onready var health_pot_btn = $PotionsBtns/HealthPotBtn
onready var mana_pot_btn = $PotionsBtns/ManaPotBtn
onready var level_indicator = $LevelIndicator

var can_disable_health_pot = true
var can_disable_mana_pot = true

func _ready():
	dungeon_entities.battle_ui = self
	var player = dungeon_entities.player
	
	health_pot_btn.text = str(player.health_pots)
	mana_pot_btn.text = str(player.mana_pots)
	
	if int(health_pot_btn.text) <= 0:
		health_pot_btn.disabled = true
	
	if int(mana_pot_btn.text) <= 0:
		mana_pot_btn.disabled = true
	
	player.connect("wpn_changued", self, "_on_player_wpn_changued")
	player.connect("potion_consumed", self, "_on_player_pot_consumed")
	var other_wpn = player.weapons.back().instance()
	var wpn = player.weapons.front().instance()
	_on_player_wpn_changued(other_wpn, wpn)
	other_wpn.queue_free()
	wpn.queue_free()




func update_floor_indicator(value):
	level_indicator.text = "Floor:" + str(value)

func _on_player_pot_consumed(type, new_amount):
	if type == "health":
		health_pot_btn.text = str(new_amount)
		if int(health_pot_btn.text) <= 0:
			can_disable_health_pot = false
			health_pot_btn.disabled = true
		else:
			health_pot_btn.disabled = false
			can_disable_health_pot = true
	else:
		mana_pot_btn.text = str(new_amount)
		if int(mana_pot_btn.text) <= 0:
			can_disable_mana_pot = false
			mana_pot_btn.disabled = true
		else:
			mana_pot_btn.disabled = false
			can_disable_mana_pot = true
		

func _on_player_wpn_changued(old, new):
	$otherWpn.icon = old.icon
	attack_btn.icon = new.icon
	old.queue_free()
	

func set_weapon_icon(wpn):
	$AttackBtn.icon = wpn.icon


func _on_AttackBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		if player.weapon.is_in_group("staffs"):
			if player.stats.mana >= player.weapon.mana_cost:
				disable()
				player.attack()
			else:
				pass
		else:
			disable()
			player.attack()
			

func disable(disable = true):
	if can_disable_health_pot:
		health_pot_btn.disabled = disable
	attack_btn.disabled = disable
	if can_disable_mana_pot:
		mana_pot_btn.disabled = disable




func _on_ConfirmationDialog_confirmed():
	$ConfirmationDialog/confirm.play()
	for generator in get_tree().get_nodes_in_group("dungeon_generator"):
		generator.reload_level()


func _on_ChangueWpnBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		player.changue_weapon()

func _on_HealthPotBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		disable()
		player.drink_pot(0)


func _on_ManaPotBtn_button_down():
	var player = dungeon_entities.player
	if player != null:
		disable()
		player.drink_pot(1)




func _on_ConfirmationDialog_popup_hide():
	$ConfirmationDialog/cancel.play()
