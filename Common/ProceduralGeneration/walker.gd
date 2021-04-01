extends Node
class_name Walker

const DIRECTIONS = [Vector3.RIGHT, Vector3.FORWARD, Vector3.LEFT, Vector3.BACK]

var position = Vector3.ZERO
var direction = Vector3.FORWARD
var bound_box = AABB()
var step_history = []
var steps_since_turn = 0
var rooms = []

func _init(starting_position, new_bound_box):
	assert(new_bound_box.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	bound_box = new_bound_box

func walk(steps, hall_lenght):
	place_room(position)
	var rooms_map = []
	var halls_map = []
	for i in steps:
		if steps_since_turn >= hall_lenght:
			changue_direction(hall_lenght)
		if can_step():
			step_history.append(position)
		else:
			changue_direction(hall_lenght)
		if i == steps - 1:
			place_room(position)
	
	var alleys = MapTools.neighbors_map(step_history, 1)
	for alley in alleys:
		place_room(alley)
		
	for step in step_history:
		var neighbors = MapTools.get_neighbors(step)
		if (neighbors.top in step_history or neighbors.down in step_history) \
		and (neighbors.right in step_history or neighbors.left in step_history):
			if not has_diagonal(step_history, step):
				halls_map.append(step)
			else:
				rooms_map.append(step)
		else:
			halls_map.append(step)
	
	rooms_map = remove_duplicates(rooms_map)
	var ind_rooms = extract_rooms(rooms_map)
	for room in ind_rooms:
		if room.size() < 3:
			for loc in room:
				halls_map.append(loc)
				rooms_map.erase(loc)

	return {
		rooms = rooms_map,
		halls = remove_duplicates(halls_map),
		walls = MapTools.get_outline_map(remove_duplicates(step_history)),
		all = remove_duplicates(step_history)
	}
	
#given an array of positions "all_rooms" returns an array of arrays
#where every array contains the positions of one individual room
func extract_rooms(all_rooms):
	var rooms_copy = all_rooms.duplicate()
	var individual_rooms = []
	var new_room = []
	var new_room_complete = false
	while not rooms_copy.empty():
		new_room = [rooms_copy.pop_front()]
		new_room_complete = false
		while not new_room_complete:
			for cell in all_rooms:
				if has_around(new_room, cell):
					if not new_room.has(cell):
						new_room_complete = false
						new_room.append(cell)
						rooms_copy.erase(cell)
						break
					else:
						new_room_complete = true
		individual_rooms.append(new_room)
	return individual_rooms

#given a map "cells" and an individul cell "test_cell" 
#checks if "test_cell" is around of any of the elements in "cells"
func has_around(map, location):
	var neighbors = MapTools.get_neighbors(location)
	for neighbor in neighbors.values():
		if map.has(neighbor):
			return true
	return false

func has_diagonal(map, location):
	var diagonals = MapTools.get_diagonals(location)
	for diagonal in diagonals.values():
		if map.has(diagonal):
			return true
	return false

func can_step():
	var target_position = position + direction
	if bound_box.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		return true
	else:
		return false

func changue_direction(futere_steps):
	if randf() < .30:
		place_room(position)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not bound_box.has_point(position + direction * futere_steps * 4):
		direction = directions.pop_front()

func place_room(pos):
	var size = Vector3(randi() % 4 + 3, 0, randi() % 4 + 3)
	var top_left_corner = (pos - size/2).ceil()
	rooms.append(create_room(position, size))
	for z in size.z:
		for x in size.x:
			var new_step = top_left_corner + Vector3(x, 0, z)
			if bound_box.grow(2).has_point(new_step):
				step_history.append(new_step)

func remove_duplicates(arr):
	var new_arr = []
	for i in arr:
		if not i in new_arr:
			new_arr.append(i)
	return new_arr

func create_room(pos, size):
	return {position = pos, size = size}

func get_room_center(room):
	var x_min = room.front().x
	var x_max = room.front().x
	var z_min = room.front().z
	var z_max = room.front().z
	for vector in room:
		if vector.x < x_min:
			x_min = vector.x
		if vector.x > x_max:
			x_max = vector.x
		if vector.z < z_min:
			z_min = vector.z
		if vector.z > z_max:
			z_max = vector.z
	var center = Vector3(round((x_max - x_min)/2) + x_min, 0, \
	round((z_max - z_min)/2) + z_min)
	
#	var neighbors = MapTools.get_neighbors(center)
#	for neighbor in neighbors.values():
#		if not neighbor in room or not center in room:
#			var sub_map = MapTools.neighbors_map(room, 4)
#			center = sub_map[randi() % sub_map.size()]
	return center

func get_end_room(starting_pos, ind_rooms):
	var end_room = ind_rooms.front()
	var end_room_position = get_room_center(end_room)
	for room in ind_rooms:
		var room_position = get_room_center(room)
		if starting_pos.distance_to(room_position) \
		> starting_pos.distance_to(end_room_position):
			if room_position in room and room.size():
				end_room = room
				end_room_position = get_room_center(end_room)
	return end_room

func get_start_room(ind_rooms):
	var min_room = ind_rooms.front()
	for room in ind_rooms:
		if room.size() < min_room.size():
			min_room = room
	return min_room
	
func get_random_room():
	return rooms[randi() % rooms.size()]
