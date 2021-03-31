extends Node
class_name MapTools

static func neighbors_map(map, neighbors_per_location):
	var sub_map = []
	var neighbor_count = 0
	if neighbors_per_location is int:
		neighbors_per_location = [neighbors_per_location]
	for location in map:
		var neighbors = get_neighbors(location)
		for neighbor in neighbors.values():
			if map.has(neighbor):
				neighbor_count += 1
		if neighbor_count in neighbors_per_location:
			sub_map.append(location)
		neighbor_count = 0
	return sub_map

static func direction_map(map, dir):
	var neighbor_map = []
	for location in map:
		if not location + dir in map:
			neighbor_map.append(location + dir)
	return neighbor_map

#given a map of positions/cells "map" iterates over every cell
#and checks the number of adjacent cells of that cell, if the 
#number of adjacent cells matches with "surround_amount", appends
#the adjacent cell determinated by "dir_to_get" to an array to be returned
#NOTE: "surround_amount" can be an array of various permited matches
static func sub_map(map, neighbors_per_location, dir):
	return direction_map(neighbors_map(map, neighbors_per_location), dir)

static func get_outline_map(rooms):
	var walls_map = []
	var walls_map2 = []
	for location in rooms:
		var neighbors = get_neighbors(location)
		for neighbor in neighbors.values():
			if not neighbor in walls_map:
				walls_map.append(neighbor)
	for location in walls_map:
		var neighbors = get_neighbors(location)
		for neighbor in neighbors.values():
			if not neighbor in walls_map2 and \
			not neighbor in rooms:
				walls_map2.append(neighbor)
	return walls_map2
		

static func random_items(arr, n):
	var new_arr = []
	while new_arr.size() < n:
		var rand_i = randi() % arr.size()
		if not arr[rand_i] in new_arr:
			new_arr.append(arr[rand_i])
	return new_arr

static func get_neighbors(location):
	return {
		down = location + Vector3.BACK, 
		top = location + Vector3.FORWARD, 
		left = location + Vector3.LEFT, 
		right = location + Vector3.RIGHT
	}

static func get_diagonals(location):
	return {
		downleft = location + Vector3.BACK + Vector3.LEFT,
		downright = location + Vector3.BACK + Vector3.RIGHT,
		topleft = location + Vector3.FORWARD + Vector3.LEFT,
		topright = location + Vector3.FORWARD + Vector3.RIGHT,
	}
