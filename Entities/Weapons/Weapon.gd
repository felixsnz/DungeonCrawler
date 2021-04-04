extends Spatial
class_name Weapon

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")

export(PackedScene) var Spell

signal can_end_turn
export(int) var damage = 1
export(int) var mana_cost = 0

func _ready():
	pass

func _on_spell_impacted(obj):
	print("emitida senial", obj.name)
	if obj.is_in_group("world_objects"):
		print("impact on wall")
		$Timer.start(0.5)
	elif obj.is_in_group("enemies"):
		print("es spidersss")
		obj.damage(damage)
		$Timer.start(0.5)

func cast_spell():
	var player = dungeon_entities.player
	var spell = Spell.instance()
	spell.connect("impacted", self, "_on_spell_impacted")
	var world = get_tree().current_scene\
	.get_node("DungeonGen").get_node("Entities")
	spell.direction = player.get_player_direction() * -1
	spell.rotation.y = player.rotation.y
	spell.damage = damage
	world.add_child(spell)
	spell.global_transform.origin = \
	player.camera.global_transform.origin + player.get_player_direction() * -0.5
	


func _on_Timer_timeout():
	emit_signal("can_end_turn")
