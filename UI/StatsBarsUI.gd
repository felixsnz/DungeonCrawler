extends Control

const dungeon_entities = preload("res://Common/SpriptableClasses/DungeonEntities.tres")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
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
