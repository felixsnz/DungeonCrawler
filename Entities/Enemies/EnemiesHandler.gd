extends Spatial

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")
const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")

signal end_turn
export(bool) var visible_path
var enemies_steps = {}
var enemies_to_attack = []
var enemies_in_turn = []
signal enemies_steps_list_filled(list)

func _ready():
	
	
	
	
	dungeon_entities.enemies = self
	var player = dungeon_entities.player
	self.connect("enemies_steps_list_filled", player, "get_enemies_steps")



func play_turn(player_final_position):
	var player = dungeon_entities.player
	if player != null:
		enemies_steps.clear()
		fill_enemies_steps_list(player_final_position)
		if not enemies_in_turn.empty():
			
			
			reset_move_check_on_enemies()
			
			call_enemies_turn(player_final_position)
			enemies_to_attack.clear()
			if enemies_can_attack(player_final_position):
				for enmy in enemies_to_attack:
					if enmy != null:
						enmy.try_to_tackle(player, player_final_position)
						yield(enmy, "has_attacked")
					else:
						pass
#						print("enemy was null")
				emit_signal("end_turn")
			else:
				emit_signal("end_turn")
		else:
			emit_signal("end_turn")

func fill_enemies_steps_list(target_pos):
	update_enemies_in_turn()
	
	
	for enemy in enemies_in_turn:
		add_step_to_enemies_steps(enemy, target_pos)
	update_enemies_steps()
	emit_signal("enemies_steps_list_filled", enemies_steps)

func reset_move_check_on_enemies():
	for enemy in enemies_in_turn:
		enemy.has_moved = false

func call_enemies_turn(player_final_pos):

	for enemy in enemies_in_turn:
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
				else:
					pass
#					print("enemy has moved")
		else:
			pass
#			print("enemy target is null")

func enemies_can_attack(player_pos) -> bool:
	var player = dungeon_entities.player
	if player != null:
		for enemy in enemies_in_turn:
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



func get_enemies_to_attack(player_pos):
	var player = dungeon_entities.player
	if player != null:
		for enemy in enemies_in_turn:
			var directions = MapTools.get_directions().values()
			for dir in directions:
				var rel = (enemy.translation + dir * 4)
				if player_pos.is_equal_approx(rel):
					enemies_to_attack.append(enemy)

func update_enemies_steps():
	for enemy in enemies_steps.keys():
		if not enemy in enemies_in_turn:
			enemies_steps.erase(enemy)

func add_step_to_enemies_steps(enemy, target_pos):
	var target_step = get_target_step(enemy.translation, target_pos)
	if target_step != null:
		enemies_steps[enemy] = target_step

func get_target_step(from, to):
	var path = Global.grid_map.find_path(from, to)
	if path:
		if path.size() > 1:
			return path[1]
		else:
			pass


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



func _on_Player_player_enter_a_room(room):
	for enemy in get_children():
		var map_enemy_pos = Global.grid_map.world_to_map(enemy.translation)
		
		if map_enemy_pos in room:
			if not enemy in enemies_in_turn:
				enemies_in_turn.append(enemy)


func _on_DungeonGen_enemies_generated():
	for enmy in get_children():
		if not enmy.is_connected("dead", self, "_on_enemy_dead"):
			enmy.connect("dead", self, "_on_enemy_dead")
		if not enmy.is_connected("damaged", self, "_on_enemy_damaged"):
			enmy.connect("damaged", self, "_on_enemy_damaged")

func _on_enemy_damaged(enemy):
	
	if not enemy in enemies_in_turn:
		enemies_in_turn.append(enemy)
		

func update_enemies_in_turn():
	for enemy in enemies_in_turn:
		if enemy != null:
			if not enemy.is_inside_tree():
				enemies_in_turn.erase(enemy)
		else:
			enemies_in_turn.erase(enemy)

func _on_enemy_dead(dead_enmy):
	enemies_in_turn.erase(dead_enmy)


func _on_DungeonGen_enemies_deleted():
	enemies_in_turn.clear()
	pass # Replace with function body.
