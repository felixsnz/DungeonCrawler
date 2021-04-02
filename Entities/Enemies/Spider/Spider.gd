extends Spatial



onready var animationPlayer = $AnimationPlayer
onready var rayCastAttack = $Body/RayCastAttack
onready var rayCastCollide = $RayCastCollide
onready var stats = $Stats
onready var body = $Body

const static_directions = {
	"right": Vector3.RIGHT,
	"left": Vector3.LEFT,
	"forward": Vector3.FORWARD,
	"back": Vector3.BACK
	}

var has_moved = false



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
#	if can_move:
	var target_direction = self.translation.direction_to(target_step)
	rayCastCollide.cast_to = target_direction * cell_size
	rayCastCollide.force_raycast_update()
	if !rayCastCollide.is_colliding():
		$Tween.interpolate_property(self, "translation", translation, \
		target_step, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()

func damage(amount):
	animationPlayer.play("damage_shake")
	stats.health -= amount

func look_at_player():
	var player = Global.player
	if player != null:
		body.look_at(player.global_transform.origin, Vector3.UP)

func _on_Stats_health_changed(value):
	pass # Replace with function body.

func _on_Stats_no_health():
	animationPlayer.play("dead")
