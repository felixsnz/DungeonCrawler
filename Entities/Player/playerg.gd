extends KinematicBody

var move_inputs = {
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

var state = STATES.IDLE
var t = 0
var can_move = true


func _ready():
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1


func _unhandled_input(event):
	for dir_key in move_inputs.keys():
		if event.is_action_pressed(dir_key):
			if can_move:
				step_direction = move_inputs[dir_key]
				initial_pos = translation
				state = STATES.MOVE
				can_move = false

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
	pass

func move_state(delta):
	var scalar = tile_size
	t = delta * 15
	if not int(round(rotation_degrees.y / 45)) % 2 == 0:
		scalar = sqrt(2 * pow(tile_size, 2))
	translation = lerp(translation, initial_pos + step_direction * scalar, t)
	if translation.is_equal_approx(initial_pos + step_direction * scalar):
		state = STATES.IDLE
		print("changos move")
		can_move = true


func rotate_state(delta):
	rotation_degrees.y = lerp(rotation_degrees.y, initial_rot + turn_rotation, delta * 15)
	
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle))* -1
	move_inputs = get_directions(step_direction)
#	print("rot deg: ", rotation_degrees.y)
#	print("final deg: ", initial_rot + turn_rotation)
	if is_equal_approx(rotation_degrees.y, initial_rot + turn_rotation):
#		print("changos")
		state = STATES.IDLE
		can_move = true


