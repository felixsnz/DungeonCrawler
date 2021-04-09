extends Spatial

export(bool) var debuging_mode 

const Spider = preload("res://Entities/Enemies/Spider/Spider.tscn")
const cthulhu = preload("res://Entities/Enemies/Spider/CthulhuHead.tscn")
const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")
const Chest = preload("res://Entities/Chest.tscn")
const BOX_WIDTH = round(320/4)
const BOX_LENGTH = round(180/4)
const BOX_HEIGHT = 4
const cell_size = 4

var chest_pos = []

var BoundBox = AABB(Vector3.ZERO, Vector3(BOX_WIDTH, BOX_HEIGHT, BOX_LENGTH))

onready var gridMap = $GridMap
onready var entities = $Entities
onready var player = $Entities/Player
onready var enemies = $Entities/Enemies
onready var stairs = $Entities/Stairs

signal enemies_deleted
signal chests_ready
signal enemies_generated

var maps
var obstcle_counter = 0
var player_initial_pos
var walker
var stairs_pos

func _ready():
	if debuging_mode:
		player.changue_camera()
	initiate_level()

func initiate_level():
	randomize()
	var walker_pos = Vector3(BOX_WIDTH/2, 0, BOX_LENGTH/2).ceil()
	walker = Walker.new(walker_pos, BoundBox)
	maps = walker.walk(20 * Global._floor, 7)
	Global.maps = maps
	gridMap.initiate(maps)
	generate_dungeon()

func generate_dungeon():
	place_grid_items()
	update_player_position()
	stairs.can_reload_level = true
	update_stairs_position()
	set_process(true)
	generate_chests(Global.ind_rooms, .1)
	

func place_grid_items():
	for location in maps.all:
		gridMap.set_cell_item(location.x, location.y, location.z, 0)
	if not debuging_mode:
		for location in maps.all:
			gridMap.set_cell_item(location.x, location.y + 2, location.z, 0)
	for location in maps.walls:
		gridMap.set_cell_item(location.x, location.y + 1, location.z, 0)

func update_player_position():
	var ind_rooms = walker.extract_rooms(maps.rooms)
	Global.ind_rooms = ind_rooms
	var player_room = walker.get_start_room(ind_rooms)
	Global.player_room = player_room
	player_initial_pos = walker.get_room_center(player_room)
	player.translation = player_initial_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)

func update_stairs_position():
	var end_room = walker.get_end_room(player_initial_pos, Global.ind_rooms)
	stairs_pos = walker.get_room_center(end_room)
	if stairs_pos.is_equal_approx(player_initial_pos):
		stairs_pos = MapTools.random_items(MapTools.neighbors_map(end_room, 4), 1).front()
	var end_room_idx = gridMap.calculate_point_index(stairs_pos)
	gridMap.astar_node.set_point_disabled(end_room_idx)
	stairs.translation = stairs_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)

func generate_chests(ind_rooms, percentage):
	for ind_room in ind_rooms:
		if randf() > 0.7:
			var new_room = MapTools.neighbors_map(ind_room, 3)
			var n_chests = round(new_room.size() * percentage)
			new_room.shuffle()
			var positions = MapTools.random_items(new_room, n_chests)
			for cell_position in positions:
				var pos = cell_position * cell_size \
				+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)
				var chest = Chest.instance()
				chest.cell_pos = cell_position
				entities.call_deferred("add_child", chest)
				chest.translation = pos

func _process(_delta):
	var chests_amount = get_tree().get_nodes_in_group("chests").size()
	if chests_amount == chest_pos.size():
#		var astar = gridMap.astar_node
#		var points = astar.get_points()
		for pos in chest_pos:
			var chest_idx = gridMap.calculate_point_index(pos)
			gridMap.astar_node.set_point_disabled(chest_idx)
#		for point in points:
#			if not astar.is_point_disabled(point):
#				var cell = astar.get_point_position(point)
#				var pos = gridMap.map_to_world(cell.x, cell.y, cell.z) + Vector3.UP * 6
#				var dbg = debug_mesh.instance()
#				entities.add_child(dbg)
#				dbg.translation = pos
		emit_signal("chests_ready")
		set_process(false)

func generate_enemies(enemy, ind_rooms, porcentage, ignore_positions = null):
	var total_pos = []
	for room in ind_rooms:
		if player_initial_pos in room:
			continue
		var n_enemies = round(room.size() * porcentage)
		room.shuffle()
		var positions = MapTools.random_items(room, n_enemies, stairs_pos)
		for position in positions:
			total_pos.append(position)
		for position in positions:
			if ignore_positions != null:
				if not position in ignore_positions:
					create_instance(enemy, position * cell_size \
					+ Vector3(cell_size/2.0, 3.5, cell_size/2.0), enemies)
			else:
				create_instance(enemy, position * cell_size \
					+ Vector3(cell_size/2.0, 3.5, cell_size/2.0), enemies)
	if ignore_positions != null:
		return total_pos + ignore_positions
	else:
		return total_pos

func create_instance(Obj, trans, parent = null):
	var obj = Obj.instance()
	if parent == null:
		parent = get_tree().current_scene
	parent.call_deferred("add_child", obj)
	obj.translation = trans
	return obj

func reload_level():
	var end_room_idx = gridMap.calculate_point_index(stairs_pos)
	gridMap.astar_node.set_point_disabled(end_room_idx, false)
	$Entities/Enemies.enemies_in_turn.clear()
	Global._floor += 1
	clear_floor()
	for pos in chest_pos:
		var chest_idx = gridMap.calculate_point_index(pos)
		gridMap.astar_node.set_point_disabled(chest_idx, false)
	chest_pos.clear()
	call_deferred("initiate_level")

func clear_floor():
	gridMap.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	emit_signal("enemies_deleted")
	for obj in get_tree().get_nodes_in_group("debug_objects"):
		obj.queue_free()
	for chest in get_tree().get_nodes_in_group("chests"):
		chest.queue_free()

func _input(event):
	if event is InputEventKey and event.pressed:
		pass
#		if event.scancode == KEY_0:
#			reload_level()

func place_debug_meshes(map, color):
	for loc in map:
		var mesh = debug_mesh.instance()
		mesh.translation = loc * cell_size + \
		Vector3(cell_size/2.0, cell_size, cell_size/2.0)
		mesh.set_color(color)
		get_parent().get_node("Entities").add_child(mesh)


func _on_DungeonGen_chests_ready():
	var ocuppied_positions = generate_enemies(Spider, Global.ind_rooms, 0.04, chest_pos)
	generate_enemies(cthulhu, Global.ind_rooms, 0.04, ocuppied_positions)
	call_deferred("emit_signal", "enemies_generated")
	pass # Replace with function body.
