extends GridMap

const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")

onready var astar_node = AStar.new()

onready var map_size = get_parent().BoundBox.size
var _half_cell_size = cell_size / 2
var path_start_position = Vector3() setget _set_path_start_position
var path_end_position = Vector3() setget _set_path_end_position
var walkable_cells_list 
var _point_path = []
#var obstacles

func _ready():
	Global.grid_map = self
#	walkable_cells_list = Global.maps.all
#	add_ready_map(walkable_cells_list)
#	astar_connect_walkable_cells(walkable_cells_list)

func initiate():
	walkable_cells_list = Global.maps.all
	add_ready_map(walkable_cells_list)
	astar_connect_walkable_cells(walkable_cells_list)
#	var walkable_cells_list = astar_add_walkable_cells(obstacles)
#	var walkable_cells_list = Global.maps.all
#	add_ready_map(walkable_cells_list)
#	astar_connect_walkable_cells(walkable_cells_list)
#	call_deferred("place_debug_meshes", walkable_cells_list, Color.green)
#	call_deferred("place_debug_meshes", obstacles, Color.red)
	
func add_ready_map(map):
	for loc in map:
		var point_index = calculate_point_index(loc)
		astar_node.add_point(point_index, loc)
	
func place_debug_meshes(map, color):
	for loc in map:
		var mesh = debug_mesh.instance()
		mesh.translation = map_to_world(loc.x, 2, loc.z)
		mesh.set_color(color)
		get_parent().get_node("Entities").add_child(mesh)

func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for z in range(map_size.z):
		for x in range(map_size.x):
			if z == 0 or x == 0 or z == map_size.z-1 or x == map_size.x-1:
				var mesh = debug_mesh.instance()
				mesh.translation = map_to_world(x, 2, z)
				mesh.set_color(Color.green)
				get_parent().get_node("Entities").add_child(mesh)
			var point = Vector3(x, 0, z)
			if point in obstacles:
				continue
			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar_node.add_point(point_index, Vector3(point.x, 0, point.z))
	return points_array

func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		var points_relative = PoolVector3Array([
			Vector3(point + Vector3.BACK),
			Vector3(point + Vector3.FORWARD),
			Vector3(point + Vector3.RIGHT),
			Vector3(point + Vector3.LEFT)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, false)


# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_z in range(3):
			for local_x in range(3):
				var point_relative = Vector3(point.x + local_x - 1, 0, point.z + local_z - 1)
				var point_relative_index = calculate_point_index(point_relative)
				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)

func is_outside_map_bounds(point):
	return point.x < 0 \
	or point.y < 0 \
	or point.z < 0 \
	or point.x >= map_size.x \
	or point.y >= map_size.y \
	or point.z >= map_size.z

func calculate_point_index(point):
	return point.x + map_size.x * point.z

func find_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(point.x, point.y, point.z)
		point_world.y += 3.5
		path_world.append(point_world)
	return path_world


	
func _recalculate_path():
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	if _point_path.size() > 0:
		_point_path.remove(_point_path.size() -1)

# Setters for the start and end path values.
func _set_path_start_position(value):
	if not value in walkable_cells_list:
		return
	if is_outside_map_bounds(value):
		return
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value):
	if not value in walkable_cells_list:
		return
	if is_outside_map_bounds(value):
		return
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
