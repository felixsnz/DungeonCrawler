extends Spatial

const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")
const dungeon_entities = preload("res://Common/SpriptableClasses/DungeonEntities.tres")

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
onready var stats = $Stats

#enum STATES {
#	IDLE,
#	MOVE,
#	ROTATE,
#	ATTACK
#}
#
#var state = STATES.IDLE

func _process(delta):
#	match state:
#		STATES.IDLE:
#			idle_state()
#		STATES.MOVE:
#			move_state()
#		STATES.ROTATE:
#			rotate_state()
#		STATES.ATTACK:
#			attack_state()
#
	if Input.is_action_just_pressed("c_camera"):
		changue_camera()

signal end_turn(final_position)
#signal reach_target_movement(position)

var step_direction = Vector3.FORWARD
var turn_rotation = 0
var cell_size = 4
var weapon = null
var is_on_turn = false

func _ready():
	Global.player = self
	dungeon_entities.player = self
	camera.current = true
	debug_camera.current = false
	if is_grabing_weapon():
		set_weapon(weaponPos.get_child(0))
	
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1
	wallRayCast.cast_to = step_direction * get_direction_scalar()


#func idle_state():
#	pass
#func move_state():
#	pass
#func rotate_state():
#	pass
#func attack_state():
#	pass
	
	
func play_turn():
	is_on_turn = true
	pass

func has_weapon() -> bool:
	return weapon != null

func _unhandled_input(event):
	if is_on_turn:
		
		if event.is_action_pressed("pass_turn"):
			end_turn(self.translation)
		if $Tween.is_active():
			return
		for dir_key in move_inputs.keys():
			if event.is_action(dir_key):
				step_direction = move_inputs[dir_key]
				move(dir_key)
		for rotate_key in rotate_inputs.keys():
			if event.is_action(rotate_key):
				turn_rotation = rotate_inputs[rotate_key]
				turn_around()
		if event.is_action_pressed("click"):
			animationPlayer.play("MeleeAttack")
			yield(animationPlayer, "animation_finished")
			end_turn(self.translation)
			hitRay.force_raycast_update()
			

func move(dir_key):
	if not animationPlayer.current_animation == "MeleeAttack":
		wallRayCast.cast_to = static_inps[dir_key] * get_direction_scalar()
		wallRayCast.force_raycast_update()
		if !wallRayCast.is_colliding():
			var new_translation = translation + step_direction * get_direction_scalar()
			tween.interpolate_property(self, "translation", translation, new_translation, \
			0.6, Tween.TRANS_LINEAR)
			tween.start()
			animationPlayer.play("walking")
			end_turn(new_translation)

func stop_walking_check():
	if not tween.is_active():
		animationPlayer.stop()

func end_turn(player_pos):
	is_on_turn = false
	emit_signal("end_turn", player_pos)
	

func turn_around():
	animationPlayer.stop()
	var new_rotation = rotation_degrees
	new_rotation.y =  rotation_degrees.y + turn_rotation
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, new_rotation, \
	.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()
	var angle = deg2rad(new_rotation.y)
	step_direction = Vector3(sin(angle), 0, cos(angle))* -1
	move_inputs = MathTools.get_directions(step_direction)

func get_direction_scalar():
	var scalar = cell_size
	if not int(round(rotation_degrees.y / 45)) % 2 == 0:
		scalar = sqrt(2 * pow(cell_size, 2))
	return scalar

func check_raycast():
	if hitRay.is_colliding():
		var collider = hitRay.get_collider()
		if collider.is_in_group("hurtboxes"):
			var obj = collider.get_parent()
			if obj.is_in_group("enemies"):
				if has_weapon():
					obj.damage(weapon.damage)

func remove_weapon():
	var wpn = weaponPos.get_child(0)
	weaponPos.remove_child(wpn)
	return wpn

func damage(amount):
#	animationPlayer.play("damage_shake")
	stats.health -= amount


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

func is_grabing_weapon() -> bool:
	return weaponPos.get_child(0) != null


func _on_Stats_no_health():
	queue_free()
