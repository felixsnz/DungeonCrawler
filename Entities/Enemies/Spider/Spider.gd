extends KinematicBody

onready var animationPlayer = $AnimationPlayer

enum STATES {
	IDLE,
	CHASING,
	WANDERING
}

export var state = STATES.IDLE

export var health = 10

func _ready():
	self.health = 10
	pass

func _physics_process(delta):
	var player = Global.player
	if player != null:
		look_at(player.global_transform.origin, Vector3.UP)

func damage():
	animationPlayer.play("damage_shake")
