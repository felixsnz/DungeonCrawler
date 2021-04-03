extends Spatial

const dungeon_entities = preload("res://Common/SpriptableClasses/DungeonEntities.tres")
const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")

signal end_turn
export(bool) var visible_path
var enemies_steps = {}
var enemies_to_attack = []

func _ready():
	dungeon_entities.enemies = self
	
func play_turn(player_final_position):
	var player = dungeon_entities.player
	if player != null:
		enemies_steps.clear()
		fill_enemies_steps_list(player_final_position)
		reset_move_check_on_enemies()
		call_enemies_turn(player_final_position)
		enemies_to_attack.clear()
		if enemies_can_attack(player_final_position):
			print(enemies_to_attack.size())
			for enmy in enemies_to_attack:
				enmy.try_to_tackle(player, player_final_position)
				yield(enmy, "has_attacked")
			emit_signal("end_turn")
		else:
			emit_signal("end_turn")

func get_enemies_to_attack(player_pos):
	var player = dungeon_entities.player
	if player != null:
		for enemy in get_children():
			var directions = MapTools.get_directions().values()
			for dir in directions:
				var rel = (enemy.translation + dir * 4)
				if player_pos.is_equal_approx(rel):
					enemies_to_attack.append(enemy)

func enemies_can_attack(player_pos) -> bool:
	var player = dungeon_entities.player
	if player != null:
		for enemy in get_children():
			var directions = MapTools.get_directions().values()
			for dir in directions:
				var rel = (enemy.translation + dir * 4)
				if player_pos.is_equal_approx(rel):
					enemies_to_attack.append(enemy)
		if enemies_to_attack.size() > 0:
			return true
		return false
	else:
		return false

func fill_enemies_steps_list(target_pos):
	for enemy in get_children():
		add_step_to_enemies_steps(enemy, target_pos)

func call_enemies_turn(player_final_pos):
	for enemy in get_children():
		var target_step = get_target_step(enemy.translation, player_final_pos)
		if target_step != null:
			enemies_steps.erase(enemy)
			if target_step in enemies_steps.values():
				var share_step_enemies = []
				for i in enemies_steps.values().size():
					if enemies_steps.values()[i] == target_step:
						share_step_enemies.append(enemies_steps.keys()[i])
				share_step_enemies.shuffle()
				var enabled_enemy = share_step_enemies.pop_front()
				for shrd_enemy in share_step_enemies:
					shrd_enemy.end_turn()
				if not enabled_enemy.has_moved:
					enabled_enemy.make_step(player_final_pos, target_step)
					enabled_enemy.has_moved = true
			else:
				if not enemy.has_moved:
					enemy.make_step(player_final_pos, target_step)
					enemy.has_moved = true

func reset_move_check_on_enemies():
	for enemy in get_children():
		enemy.has_moved = false

func add_step_to_enemies_steps(enemy, target_pos):
	var target_step = get_target_step(enemy.translation, target_pos)
	if target_step != null:
		enemies_steps[enemy] = target_step

func get_target_step(from, to):
	var path = Global.grid_map.find_path(from, to)
	if path and path.size() > 1:
		return path[1]
	else:
		return null

func disable_points(points, disabled = true):
	var astar_node = Global.grid_map.astar_node
	var grid = Global.grid_map
	for point in points:
		var map_point = grid.world_to_map(point)
		astar_node.set_point_disabled(grid.calculate_point_index(map_point), disabled)

func generate_path(path):
	for location in path:
		var deb_mesh = debug_mesh.instance()
		deb_mesh.translation = location
		deb_mesh.set_color(Color.purple)
		get_parent().call_deferred("add_child", deb_mesh)

func clear_path():
	if visible_path:
		for mesh in get_tree().get_nodes_in_group("debug_objects"):
			if mesh.get_surface_material(0).albedo_color == Color.purple:
				mesh.queue_free()

