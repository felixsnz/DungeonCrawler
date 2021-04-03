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



signal end_turn(final_position)
#signal reach_target_movement(position)

var step_direction = Vector3.FORWARD
var turn_rotation = 0
var cell_size = 4
var weapon = null
var is_on_turn = false
var enemies_steps_copy = []

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

func _process(_delta):
	if Input.is_action_just_pressed("c_camera"):
		changue_camera()

func _unhandled_input(event):
	if is_on_turn:
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
			if has_weapon():
				if weapon.is_in_group("staffs"):
					print("player has this mana:" , stats.mana)
					if stats.mana >= weapon.mana_cost:
						is_on_turn = false
						print("staff attack")
						animationPlayer.play("SpellAttack")
						yield(weapon, "spell_impacted")
						end_turn(self.translation)
					else:
						print("no mana")
						pass
				if weapon.is_in_group("melees"):
					animationPlayer.play("MeleeAttack")
					is_on_turn = false
					hitRay.force_raycast_update()
					yield(animationPlayer, "animation_finished")
					end_turn(self.translation)

func staff_attack():
	stats.mana -= weapon.mana_cost
	weapon.cast_spell()

func get_enemies_steps(list):
	enemies_steps_copy = list.values()

func move(dir_key):
	if not animationPlayer.current_animation == "MeleeAttack":
		wallRayCast.cast_to = static_inps[dir_key] * get_direction_scalar()
		wallRayCast.force_raycast_update()
		var new_translation = translation + step_direction * get_direction_scalar()
		if !wallRayCast.is_colliding() and not new_translation in enemies_steps_copy:
			tween.interpolate_property(self, "translation", translation, new_translation, \
			0.6, Tween.TRANS_LINEAR)
			tween.start()
			animationPlayer.play("walking")
			end_turn(new_translation)

func play_turn():
	is_on_turn = true

func has_weapon() -> bool:
	return weapon != null

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

func get_player_direction():
	return Vector3(sin(rotation.y), 0, cos(rotation.y))

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
