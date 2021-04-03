extends Spatial

onready var animationPlayer = $AnimationPlayer
onready var rayCastAttack = $BodyAxis/Body/RayCastAttack
onready var rayCastCollide = $RayCastCollide
onready var stats = $Stats
onready var body = $BodyAxis/Body
onready var hurtBox = $HurtBox

const static_directions = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK
	}

var has_moved = false
var can_move = true
var can_attack = true
var damage = 1

signal has_attacked

enum STATES {
	IDLE,
	CHASING,
	WANDERING
}

var state = STATES.IDLE
var cell_size = 4

func _ready():
	pass

func _physics_process(_delta):
	look_at_player()

func get_target_step(target_pos):
	var path = Global.grid_map.find_path(self.translation, target_pos)
	if path and path.size() > 1:
		return path[1]
	else:
		return null

func make_step(target_step):
	if can_move:
		var target_direction = self.translation.direction_to(target_step)
		rayCastCollide.cast_to = target_direction * cell_size
		rayCastCollide.force_raycast_update()
		if !rayCastCollide.is_colliding():
			$Tween.interpolate_property(self, "translation", translation, \
			target_step, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()


func try_to_tackle(player, player_pos):
	if can_attack:
		if player.tween.is_active():
			yield(player.tween, "tween_completed")
		var directions = static_directions.values()
		for dir in directions:
			var rel = self.translation + dir * cell_size
			if rel.is_equal_approx(player_pos):
				animationPlayer.play("tackle")

func check_raycast():
	if rayCastAttack.is_colliding():
		var collider = rayCastAttack.get_collider()
		var obj = collider.get_parent()
		obj.damage(damage)

func disable_movement():
	can_attack = false
	can_move = false
	hurtBox.get_node("CollisionShape").disabled = true

func damage(amount):
	animationPlayer.play("damage_shake")
	stats.health -= amount

func end_turn():
	emit_signal("has_attacked")
	

func look_at_player():
	var player = Global.player
	if player != null and can_move:
		$BodyAxis.look_at(player.global_transform.origin, Vector3.UP)

func _on_Stats_health_changed(value):
	pass # Replace with function body.

func _on_Stats_no_health():
	animationPlayer.play("dead")
