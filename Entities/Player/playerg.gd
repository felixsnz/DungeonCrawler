extends Spatial

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


onready var hitRay = $Head/Camera/HitRay
onready var animationPlayer = $Head/AnimationPlayer
onready var wallRayCast = $RayCast

func _ready():
	Global.player = self
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1
	wallRayCast.cast_to = step_direction * get_direction_scalar()

func _process(delta):
	if Input.is_action_pressed("click"):
		animationPlayer.play("MeleeAttack")
		yield(animationPlayer, "animation_finished")
		hitRay.force_raycast_update()

func _unhandled_input(event):
	if $Tween.is_active():
		return
	for dir_key in move_inputs.keys():
		if event.is_action_pressed(dir_key):
			step_direction = move_inputs[dir_key]
			move(dir_key)
	for rotate_key in rotate_inputs.keys():
		if event.is_action_pressed(rotate_key):
			turn_rotation = rotate_inputs[rotate_key]
			turn_around()

func move(dir_key):
	wallRayCast.cast_to = static_inps[dir_key] * get_direction_scalar()
	wallRayCast.force_raycast_update()
	if !wallRayCast.is_colliding():
		var new_translation = translation + step_direction * get_direction_scalar()
		$Tween.interpolate_property(self, "translation", translation, new_translation, \
		1.0/3.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()

func turn_around():
	var new_rotation = rotation_degrees
	new_rotation.y =  rotation_degrees.y + turn_rotation
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, new_rotation, \
	1.0/3.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	var angle = deg2rad(new_rotation.y)
	step_direction = Vector3(sin(angle), 0, cos(angle))* -1
	move_inputs = get_directions(step_direction)

func get_directions(forward_reference):
	return {
	"right": forward_reference.cross(Vector3.UP),
	"left": -forward_reference.cross(Vector3.UP),
	"forward": forward_reference,
	"back": forward_reference * -1
	}

func get_direction_scalar():
	var scalar = tile_size
	if not int(round(rotation_degrees.y / 45)) % 2 == 0:
		scalar = sqrt(2 * pow(tile_size, 2))
	return scalar

func check_raycast():
	if hitRay.is_colliding():
		var obj = hitRay.get_collider()
		obj.damage()
