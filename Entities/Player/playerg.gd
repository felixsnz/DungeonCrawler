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
	"turn_right":-90,
	"turn_left":90
	}

onready var hitRay = $Head/Camera/HitRay
onready var animationPlayer = $Head/AnimationPlayer
onready var weaponPos = $Head/Camera/WeaponPos
onready var wallRayCast = $RayCast
onready var tween = $Tween
onready var camera = $Head/Camera
onready var debug_camera = $debugCamera

var step_direction = Vector3.FORWARD
var turn_rotation = 0
var tile_size = 4
var weapon 

func _ready():
	Global.player = self
	camera.current = true
	debug_camera.current = false
	
	if has_weapon():
		set_weapon(weaponPos.get_child(0))
	
	
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1
	wallRayCast.cast_to = step_direction * get_direction_scalar()

func _process(_delta):
	if Input.is_action_pressed("click"):
		animationPlayer.play("MeleeAttack")
		yield(animationPlayer, "animation_finished")
		hitRay.force_raycast_update()
	if Input.is_action_just_pressed("c_camera"):
		changue_camera()
		

		

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
		tween.interpolate_property(self, "translation", translation, new_translation, \
		1.0/3.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween.start()
		call_enemy_turn(new_translation)

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
	
func call_enemy_turn(player_pos):
	get_tree().call_group("enemies", "make_a_step", player_pos)

func get_direction_scalar():
	var scalar = tile_size
	if not int(round(rotation_degrees.y / 45)) % 2 == 0:
		scalar = sqrt(2 * pow(tile_size, 2))
	return scalar

func check_raycast():
	if hitRay.is_colliding():
		var collider = hitRay.get_collider()
		if collider.is_in_group("hurtboxes"):
			var obj = collider.get_parent()
			if obj.is_in_group("enemies"):
				obj.damage(weapon.damage)




func set_weapon(new_weapon = null):
	if new_weapon != null:
		if new_weapon.is_in_group("weapons"):
			if new_weapon is Weapon:
				self.weapon = new_weapon

func changue_camera():
	if camera.current:
		camera.current = false
		debug_camera = true
	else:
		camera.current = true
		debug_camera = false

func has_weapon() -> bool:
	var wpn = weaponPos.get_child(0)
	if wpn != null:
		if wpn.is_in_group("weapons"):
			if wpn is Weapon:
				return true
			else:
				push_error("obj is not a Weapon node")
				return false
		else:
			push_error("obj not in weapons group")
			return false
	else:
		push_error("no obj in weaponPos")
		return false
