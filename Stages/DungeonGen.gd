extends Spatial

onready var Spider = preload("res://Entities/Enemies/Spider/Spider.tscn")
onready var Player = preload("res://Entities/Player/Player.tscn")

const BOX_WIDTH = round(320/7)
const BOX_LENGTH = round(180/7)
const BOX_HEIGHT = 4
const cell_size = 4

var BoundBox = AABB(Vector3.ZERO, Vector3(BOX_WIDTH, BOX_HEIGHT, BOX_LENGTH))

onready var grid = $GridMap
onready var entities = $Entities
var maps
var obstcle_counter = 0
func _ready():
	
	randomize()
	generate_dungeon()
	$GridMap.obstacles = MapTools.get_cell_by_id($GridMap, 2)
	print($GridMap.obstacles.size())
	$GridMap.initiate()
	print($GridMap.obstacles.size())

func reload_leve():
	get_tree().reload_current_scene()

func generate_dungeon():
	
	var walker_pos = Vector3(BOX_WIDTH/2, 0, BOX_LENGTH/2).ceil()
	var walker = Walker.new(walker_pos, BoundBox)
	maps = walker.walk(150, 8)
	Global.maps = maps
	
#	for location in maps.rooms:
#		grid.set_cell_item(location.x, location.y, location.z, 2)
	
	for location in maps.all:
		grid.set_cell_item(location.x, location.y, location.z, 1)
#	for location in maps.all:
#		grid.set_cell_item(location.x, location.y + 2, location.z, 0)
	for location in maps.walls:
		grid.set_cell_item(location.x, location.y + 1, location.z, 0)
	for location in maps.walls:
		grid.set_cell_item(location.x, 0, location.z, 2)
		obstcle_counter +=1
	print("real shit: ", obstcle_counter)
		
	var ind_rooms = walker.extract_rooms(maps.rooms)
		
	var player_room = walker.get_start_room(ind_rooms)
	
	var player = Player.instance()
	var player_pos = walker.get_room_center(player_room)
#	print("grid player location: ", player_pos)
	player.translate(player_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0))
	$Entities.add_child(player)
	print("player_transform", player.translation)
	
	var spider = Spider.instance()
	var spider_pos = MapTools.random_items(player_room, 1).front()
#	print("grid spider location: ", spider_pos)
	spider.translate(spider_pos * cell_size + \
	Vector3(cell_size/2.0, cell_size, cell_size/2.0))
	$Entities.call_deferred("add_child", spider)

#	print("spider_transfor", spider.translation)

#func place_grid(gridmap, map, g_index):
#	for location in map:
#		gridmap.set_cell_item()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_0:
			reload_leve()
		if event.scancode == KEY_1:
			for location in maps.rooms:
				grid.set_cell_item(location.x, location.y, location.z, 2)
		if event.scancode == KEY_2:
			for location in maps.halls:
				grid.set_cell_item(location.x, location.y, location.z, 1)
		if event.scancode == KEY_3:
			reload_leve()
		if event.scancode == KEY_4:
			reload_leve()

func choose(list):
	randomize()
	return list[randi() % list.size()]
