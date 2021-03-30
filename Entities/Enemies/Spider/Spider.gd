extends KinematicBody

const TYPE = "ENEMY"
const GRAVITY = -9.8 * 3
const MAX_SPEED = 12
const MAX_RUNNING_SPEED = 24
const ACCEL = 8
const DEACCEL = 12
const MAX_SLOPE_ANGLE = -45
const JUMP_HEIGHT = 12.5
const DAMAGE = 4

enum STATES {
	IDLE,
	CHASING,
	WANDERING
}

export var state = STATES.IDLE

var vel = Vector3()
var dir = Vector3()

export var speed = 6

export var health = 10
#onready var player = get_node("../../Player")

func _ready():
	self.health = 10
	pass
#
#func _physics_process(delta):
#	Physics(delta)
#
#	match (state):
#		STATES.IDLE:
#			Idle()
#		STATES.CHASING:
#			Chasing(delta)
#		STATES.WANDERING:
#			Wandering()
#
#	if (!is_on_floor()):
#		vel.y += GRAVITY * delta
#	else:
#		vel.y = 0
#
#	dir.x = global_transform.origin.x - player.global_transform.origin.x
#	dir.z = global_transform.origin.z - player.global_transform.origin.z
#
#	dir.y = 0
#	dir = dir.normalized()
#
#	vel = move_and_slide(vel, Vector3(0, 1, 0))
#	pass
#
#func Chasing(delta):
#	chase_target(player, delta)
#	pass
#
#func Physics(delta):
#	pass
#
#func Wandering():
#	pass
#
#func Idle():
#	pass
#
#func chase_target(t, delta):
#	var temp_velocity = vel
#	temp_velocity.y = 0
#	var acceleration
#	if (dir.dot(temp_velocity) > 0):
#		acceleration = ACCEL
#	else:
#		acceleration = DEACCEL
#	temp_velocity.y = 0
#	var target = dir * speed
#	temp_velocity = temp_velocity.linear_interpolate(-target, acceleration * delta)
#	dir.x = global_transform.origin.x - player.global_transform.origin.x
#	dir.z = global_transform.origin.z - player.global_transform.origin.z
#	dir.y = 0
#	dir = dir.normalized()
