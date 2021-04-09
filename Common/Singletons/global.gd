extends Node

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

var player = null
var actual_dialog = null
var maps = null
var grid_map = null
var player_room = null
var ind_rooms = null
var _floor = 1 setget set_floor

func set_floor(value):
	dungeon_entities.battle_ui.update_floor_indicator(value)
	_floor = value
