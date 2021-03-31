extends KinematicBody

var move_inputs = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK
	}

const static_inps = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK
	}

var rotate_inputs = {
	"turn_right":-45,
	"turn_left":45
	}

var step_direction = Vector3.FORWARD
var turn_rotation = 0
var tile_size = 4
var initial_pos = Vector3.ZERO
var initial_rot = 0

enum STATES {
	IDLE,
	MOVE,
	ROTATE
}

onready var hitRay = $Head/Camera/HitRay
onready var wallRayCast = $RayCast
onready var rayshape = $Raicast

var state = STATES.IDLE
var t = 0
var can_move = true


func _ready():
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1
	wallRayCast.cast_to = step_direction * get_direction_scalar()


func _unhandled_input(event):
	for dir_key in move_inputs.keys():
		if event.is_action_pressed(dir_key):
			if can_move:
				step_direction = move_inputs[dir_key]
				var scalar = get_direction_scalar()
				wallRayCast.cast_to = static_inps[dir_key] * scalar
				wallRayCast.force_raycast_update()
				if !wallRayCast.is_colliding():
					initial_pos = translation
					state = STATES.MOVE
					can_move = false
				else:
					can_move = true
					state = STATES.IDLE

	for rotate_key in rotate_inputs.keys():
		if event.is_action_pressed(rotate_key):
			if can_move:
				turn_rotation = rotate_inputs[rotate_key]
				initial_rot = rotation_degrees.y
				state = STATES.ROTATE
				can_move = false

				
				
func _physics_process(delta):
	match state:
		STATES.IDLE:
			idle_state()
		STATES.MOVE:
			move_state(delta)
		STATES.ROTATE:
			rotate_state(delta)

func get_directions(forward_reference):
	return {
	"right": forward_reference.cross(Vector3.UP),
	"left": -forward_reference.cross(Vector3.UP),
	"forward": forward_reference,
	"back": forward_reference * -1
	}

func idle_state():
	t = 0

func move_state(delta):
	
	
#	hitRay.enabled = true
#	hitRay.cast_to = step_direction * scalar
#	hitRay.force_raycast_update()
#	if !hitRay.is_colliding():
	var scalar = get_direction_scalar()
	t += delta
	translation = lerp(translation, initial_pos + step_direction * scalar, t)
	if translation.is_equal_approx(initial_pos + step_direction * scalar):
		hitRay.enabled = false
		state = STATES.IDLE
		can_move = true
#	else:
#		hitRay.enabled = false
#		state = STATES.IDLE
#		can_move = true

func get_direction_scalar():
	var scalar = tile_size
	if not int(round(rotation_degrees.y / 45)) % 2 == 0:
		scalar = sqrt(2 * pow(tile_size, 2))
	return scalar


func rotate_state(delta):
	t += delta
	rotation_degrees.y = lerp(rotation_degrees.y, initial_rot + turn_rotation, t)
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle))* -1
	move_inputs = get_directions(step_direction)
	if is_equal_approx(rotation_degrees.y, initial_rot + turn_rotation):
		state = STATES.IDLE
		can_move = true

func has_wall_infront():
	var boolean = false
	hitRay.enabled
	
