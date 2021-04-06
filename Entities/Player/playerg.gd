extends Spatial

const debug_mesh = preload("res://Debug&Test/debug_mesh.tscn")
const dungeon_entities = preload("res://Common/SpriptableClasses/battle_units.tres")

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
onready var step_audio = $Head/AudioStreamPlayer3D

var speed = 1.5

signal end_turn(final_position)
signal wpn_changued(old, new)
signal potion_consumed(pot, new_amount)
#signal reach_target_movement(position)

var step_direction = Vector3.FORWARD
var turn_rotation = 0
var cell_size = 4

export(Array, PackedScene) var weapons = []

var weapon = null
var is_on_turn = true
var enemies_steps_copy = []
var can_walk = true
var health_pots = 6
var mana_pots = 6

func _ready():
	Global.player = self
	dungeon_entities.player = self
	camera.current = true
	debug_camera.current = false
	set_weapon(weapons.front().instance())
	
#	if weapon.is_in_group("staffs"):
#		connect_weapon_end_turn_signal()
	
	var angle = deg2rad(rotation_degrees.y)
	step_direction = Vector3(sin(angle), 0, cos(angle)) * -1
	wallRayCast.cast_to = step_direction * get_direction_scalar()

func _process(_delta):
	if Input.is_action_just_pressed("c_camera"):
		changue_camera()
	if Input.is_action_just_pressed("down"):
		print("kkkkk")
		can_walk = not can_walk

func play_step_audio():
	step_audio.play()

func play_drink_sound():
	$Head/Camera/PotionPos/AudioStreamPlayer.play()

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

func attack():
	if has_weapon():
		if weapon.is_in_group("staffs"):
			if stats.mana >= weapon.mana_cost:
				is_on_turn = false
				animationPlayer.play("SpellAttack")
				yield(weapon, "can_end_turn")
				end_turn(self.translation)
			else:
				pass
		if weapon.is_in_group("melees"):
			animationPlayer.play("MeleeAttack")
			is_on_turn = false
			hitRay.force_raycast_update()
			yield(animationPlayer, "animation_finished")
			end_turn(self.translation)

func drink_pot(idx):
	$Head/Camera/PotionPos.get_child(idx).show()
	$Head/Camera/PotionPos.get_child(abs(idx - 1)).hide()
	animationPlayer.play_backwards("set_weapon")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("drink_pot")
	yield(animationPlayer, "animation_finished")
	if idx == 0:
		stats.health += 15
		health_pots -= 1
		emit_signal("potion_consumed", "health", health_pots)
	else:
		stats.mana += 20
		mana_pots -= 1
		emit_signal("potion_consumed", "mana", mana_pots)
	animationPlayer.play("set_weapon")
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
		var stairs_pos = get_parent().get_parent().stairs_pos
		if new_translation.is_equal_approx(stairs_pos * cell_size \
	+ Vector3(cell_size/2.0, 3.5, cell_size/2.0)):
			dungeon_entities.battle_ui.ask_for_next_level()
		if !wallRayCast.is_colliding() and not new_translation in enemies_steps_copy:
			tween.interpolate_property(self, "translation", translation, new_translation, \
			1/speed, Tween.TRANS_LINEAR)
			tween.start()
			if can_walk:
				animationPlayer.play("walking")
			end_turn(new_translation)
			dungeon_entities.battle_ui.hide_popup()

func play_turn():
	is_on_turn = true


func stop_walking_check():
	if not tween.is_active():
		animationPlayer.stop()

func end_turn(player_pos = self.translation):
	is_on_turn = false
	emit_signal("end_turn", player_pos)

func turn_around():
	animationPlayer.stop()
	var new_rotation = rotation_degrees
	new_rotation.y =  rotation_degrees.y + turn_rotation
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, new_rotation, \
	.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()
	$Head/Rotation.play()
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
					$Head/Camera/WeaponPos/meleeHitSound.play()
					obj.damage(weapon.damage)

func has_weapon() -> bool:
	return weapon != null

func changue_weapon():
	animationPlayer.play_backwards("set_weapon")
	yield(animationPlayer, "animation_finished")
	weapon.queue_free()
	weapons.invert()
	var new_weapon = weapons.front().instance()
	set_weapon(new_weapon)
	emit_signal("wpn_changued", weapons.back().instance(), new_weapon)
	

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
	print("setting new weapo")
	if new_weapon != null:
		if new_weapon.is_in_group("weapons"):
			if new_weapon is Weapon:
				print("setting new wapo")
				weaponPos.add_child(new_weapon)
				self.weapon = new_weapon
				animationPlayer.play("set_weapon")

func changue_camera():
	if camera.current:
		camera.current = false
		debug_camera = true
	else:
		camera.current = true
		debug_camera = false

func _on_Stats_no_health():
	queue_free()
