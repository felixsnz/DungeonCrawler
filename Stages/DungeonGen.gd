extends Spatial

export(bool) var debuging_mode 

const Spider = preload("res://Entities/Enemies/Spider/Spider.tscn")
const cthulhu = preload("res://Entities/Enemies/Spider/CthulhuHead.tscn")
const Player = preload("res://Entities/Player/Player.tscn")
const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")
const Stairs = preload("res://Entities/Stairs.tscn")
const BOX_WIDTH = round(320/4)
const BOX_LENGTH = round(180/4)
const BOX_HEIGHT = 4
const cell_size = 4

var BoundBox = AABB(Vector3.ZERO, Vector3(BOX_WIDTH, BOX_HEIGHT, BOX_LENGTH))

onready var gridMap = $GridMap
onready var entities = $Entities
onready var player = $Entities/Player
onready var enemies = $Entities/Enemies


var maps
var obstcle_counter = 0
var player_initial_pos
var walker
var stairs_pos
var stairs

func _ready():
	initiate_level()
	

func initiate_level():
	randomize()
	var walker_pos = Vector3(BOX_WIDTH/2, 0, BOX_LENGTH/2).ceil()
	walker = Walker.new(walker_pos, BoundBox)
	maps = walker.walk(50, 7)
	Global.maps = maps
	
#	gridMap.obstacles = MapTools.get_cell_by_id(gridMap, 2)
	gridMap.initiate()
	generate_dungeon()
	

func reload_level():
	gridMap.clear()
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()

	stairs.queue_free()
	
	call_deferred("initiate_level")
	
	



func generate_dungeon():
	
	
#	for x in BoundBox.size.x:
#		for z in BoundBox.size.z:
#			var mesh = debug_mesh.instance()
#			mesh.translation = Vector3(x, 3, z) * cell_size + \
#			Vector3(cell_size/2.0, cell_size, cell_size/2.0)
#			mesh.set_color(Color.blue)
#			get_node("Entities").add_child(mesh)
	
	
#	for location in maps.rooms:
#		grid.set_cell_item(location.x, location.y, location.z, 2)
	for location in maps.all:
		gridMap.set_cell_item(location.x, location.y, location.z, 0)
	if not debuging_mode:
		for location in maps.all:
			gridMap.set_cell_item(location.x, location.y + 2, location.z, 0)
	for location in maps.walls:
		gridMap.set_cell_item(location.x, location.y + 1, location.z, 0)
	for location in maps.walls:
		gridMap.set_cell_item(location.x, 0, location.z, 2)
		obstcle_counter +=1

		
	var ind_rooms = walker.extract_rooms(maps.rooms)
		
	var player_room = walker.get_start_room(ind_rooms)
	
	player_initial_pos = walker.get_room_center(player_room)
	
	var end_room = walker.get_end_room(player_initial_pos, ind_rooms)
	
	stairs_pos = walker.get_room_center(end_room)
	
	stairs = Stairs.instance()
	
	var end_room_idx = gridMap.calculate_point_index(stairs_pos)
	gridMap.astar_node.set_point_disabled(end_room_idx)
#	var points = gridMap.astar_node.get_points()
#	for point in points:
#		print(point)
#		var dbg = debug_mesh.instance()
#		var pos = gridMap.astar_node.get_point_position(point)
#		dbg.translation = gridMap.map_to_world(pos.x, pos.y, pos.z) + Vector3(0,6,0)
#		entities.add_child(dbg)
	
	stairs.translation = stairs_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)
	
	entities.add_child(stairs)
	
	player.translation = player_initial_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)
	if debuging_mode:
		player.changue_camera()
	
	generate_enemies(Spider, ind_rooms, 0.03)
	generate_enemies(cthulhu, ind_rooms, 0.03)
#	create_instance(Spider, MapTools.random_items(player_room, 1).front() * cell_size \
#			+ Vector3(cell_size/2.0, 3.5, cell_size/2.0), enemies)

func generate_enemies(enemy, ind_rooms, porcentage):
	for room in ind_rooms:
		if player_initial_pos in room:
			continue
		var n_enemies = round(room.size() * porcentage)
		room.shuffle()
		var positions = MapTools.random_items(room, n_enemies, stairs_pos)
		for position in positions:
			create_instance(enemy, position * cell_size \
			+ Vector3(cell_size/2.0, 3.5, cell_size/2.0), enemies)
#	call_deferred("emit_signal", "enemies_generated")

func create_instance(Obj, trans, parent = null):
	var obj = Obj.instance()
	if parent == null:
		parent = get_tree().current_scene
	parent.call_deferred("add_child", obj)
	obj.translation = trans
	return obj
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_0:
			reload_level()
		if event.scancode == KEY_1:
			for location in maps.rooms:
				gridMap.set_cell_item(location.x, location.y, location.z, 2)
		if event.scancode == KEY_2:
			for location in maps.halls:
				gridMap.set_cell_item(location.x, location.y, location.z, 1)

func place_debug_meshes(map, color):
	for loc in map:
		var mesh = debug_mesh.instance()
		mesh.translation = loc * cell_size + \
		Vector3(cell_size/2.0, cell_size, cell_size/2.0)
		mesh.set_color(color)
		get_parent().get_node("Entities").add_child(mesh)

func choose(list):
	randomize()
	return list[randi() % list.size()]
