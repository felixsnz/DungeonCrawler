extends Node

export(int) var max_health setget set_max_health
var health = 0 setget set_health
var health_full = false

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func _ready():
	self.health = max_health
#	self.ammo = max_ammo

func set_health(value):
	health = clamp(value, 0, max_health)
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

#export(int) var max_ammo setget set_max_ammo
#var ammo = 0 setget set_ammo
#var ammo_full = false
#
#signal no_ammo
#signal ammo_changed(value)
#signal max_ammo_changed(value)
#
#func set_ammo(value):
#	var initial_ammo = ammo
#	ammo = clamp(value, 0, max_ammo)
#	if initial_ammo != ammo:
#		emit_signal("ammo_changed", ammo)
#	if ammo <= 0:
#		emit_signal("no_ammo")
#
#func set_max_ammo(value):
#	max_ammo = value
#	self.ammo = min(ammo, max_ammo)
#	emit_signal("max_ammo_changed")
