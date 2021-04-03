extends Spatial

const dungeon_entities = preload("res://Common/SpriptableClasses/DungeonEntities.tres")

onready var player = $Player
onready var enemies = $Enemies


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_Enemies_end_turn()

func start_player_turn():
	pass

func start_enemies_turn():
	pass

func _on_Player_end_turn(final_position):
	if dungeon_entities.enemies != null:
		enemies.play_turn(final_position)
#		yield(enemies, "end_turn")
#		start_player_turn()


func _on_Enemies_end_turn():
	if dungeon_entities.player != null:
		player.play_turn()
#		yield(player, "end_turn")
#		start_enemies_turn()


