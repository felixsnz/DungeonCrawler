extends Node

const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

var player = null
var maps = null
var grid_map = null
var player_room = null
var ind_rooms = null
var level = 1 setget set_level

func set_level(value):
	dungeon_entities.battle_ui.update_lvl_indicator(value)
	level = value
