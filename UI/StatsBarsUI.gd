extends Control
const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

var can_end = true

func _ready():
	var player = dungeon_entities.player
	if player != null:
		player.stats.connect("health_changed", self, "_on_player_stats_health_changued")
		player.stats.connect("mana_changed", self, "_on_player_stats_mana_changued")
		$PlayerHealthBar.initialize(player.stats.max_health)
		$PlayerHealthBar.update_bar(player.stats.max_health)
		
		$PlayerManaBar.initialize(player.stats.max_mana)
		$PlayerManaBar.update_bar(player.stats.max_mana)


func _on_player_stats_health_changued(value):
	$PlayerHealthBar.update_bar(value)

func _on_player_stats_mana_changued(value):
	$PlayerManaBar.update_bar(value)


func _on_PlayerHealthBar_no_health():
	if can_end:
		
		get_parent().get_parent().get_node("Control").queue_free()
		dungeon_entities.player.queue_free()
		get_parent().get_parent().get_node("DeathScreen").popup()
		can_end = false


func _on_ValueBar_value_changed(value):
	
	if value <= 0 and can_end:
		
		get_parent().get_parent().get_node("Control").queue_free()
		dungeon_entities.player.queue_free()
		get_parent().get_parent().get_node("DeathScreen").popup()
		can_end = false
