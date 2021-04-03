extends Spatial
class_name Weapon

const dungeon_entities = preload("res://Common/SpriptableClasses/DungeonEntities.tres")

const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")

export(PackedScene) var Spell

signal spell_impacted
export(int) var damage = 1
export(int) var mana_cost = 0

func _ready():
	pass

func _on_spell_impacted():
	emit_signal("spell_impacted")

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
	player.camera.global_transform.origin + player.get_player_direction() * -1
	
