extends Node

export(int) var max_health setget set_max_health
var health = 0 setget set_health
var health_full = false

export(int) var max_mana setget set_max_mana
var mana = 0 setget set_mana
var mana_full = false

signal no_mana
signal mana_changed(value)
signal max_mana_changed(value)

signal no_health
signal health_changed(value)
signal health_reduced
signal max_health_changed(value)

func _ready():
	self.health = max_health
	self.mana = max_mana

func set_health(value):
	var initial_health = self.health
	health = clamp(value, 0, max_health)
	
	if health < initial_health:
		emit_signal("health_reduced")
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
	if health != max_health:
		health_full = false
	else:
		health_full = true

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed")

func set_mana(value):
	var initial_mana = mana
	mana = clamp(value, 0, max_mana)
	if initial_mana != mana:
		emit_signal("mana_changed", mana)
	if mana <= 0:
		emit_signal("no_mana")
	if mana != max_mana:
		mana_full = false
	else:
		mana_full = true


func set_max_mana(value):
	max_mana = value
	self.mana = min(mana, max_mana)
	emit_signal("max_mana_changed")
