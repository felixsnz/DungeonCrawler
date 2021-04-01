extends Spatial

export(bool) var debuging_mode 

const Spider = preload("res://Entities/Enemies/Spider/Spider.tscn")
const Player = preload("res://Entities/Player/Player.tscn")
const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")
const BOX_WIDTH = round(320/4)
const BOX_LENGTH = round(180/4)
const BOX_HEIGHT = 4
const cell_size = 4

var BoundBox = AABB(Vector3.ZERO, Vector3(BOX_WIDTH, BOX_HEIGHT, BOX_LENGTH))

onready var gridMap = $GridMap
onready var entities = $Entities
var maps
var obstcle_counter = 0
var player_initial_pos
func _ready():
	randomize()
	generate_dungeon()
#	gridMap.obstacles = MapTools.get_cell_by_id(gridMap, 2)
	gridMap.initiate()

func reload_leve():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()



func generate_dungeon():
	var walker_pos = Vector3(BOX_WIDTH/2, 0, BOX_LENGTH/2).ceil()
	var walker = Walker.new(walker_pos, BoundBox)
	maps = walker.walk(200, 7)
	Global.maps = maps
	
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
		gridMap.set_cell_item(location.x, location.y, location.z, 1)
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
	
	var player = Player.instance()
	player_initial_pos = walker.get_room_center(player_room)

	player.translate(player_initial_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0))
	$Entities.add_child(player)
	if debuging_mode:
		player.changue_camera()
	
	var spider = Spider.instance()
	var spider_pos = MapTools.random_items(player_room, 1).front()
	while spider_pos == player_initial_pos:
		spider_pos = MapTools.random_items(player_room, 1).front()
		
	spider.translate(spider_pos * cell_size + \
	Vector3(cell_size/2.0, 3.5, cell_size/2.0))
	$Entities.call_deferred("add_child", spider)
	
	generate_enemies(Spider, ind_rooms, 0.06)

func generate_enemies(enemy, ind_rooms, porcentage):
	for room in ind_rooms:
		if player_initial_pos in room:
			continue
		var n_enemies = round(room.size() * porcentage)
		room.shuffle()
		var positions = MapTools.random_items(room, n_enemies)
		for position in positions:
			create_instance(enemy, position * cell_size \
			+ Vector3(cell_size/2.0, 3.5, cell_size/2.0), entities)
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
			reload_leve()
		if event.scancode == KEY_1:
			for location in maps.rooms:
				gridMap.set_cell_item(location.x, location.y, location.z, 2)
		if event.scancode == KEY_2:
			for location in maps.halls:
				gridMap.set_cell_item(location.x, location.y, location.z, 1)
		if event.scancode == KEY_3:
			reload_leve()
		if event.scancode == KEY_4:
			reload_leve()

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
