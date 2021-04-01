extends KinematicBody

onready var animationPlayer = $AnimationPlayer
onready var rayCast = $RayCast

var path

var tile_size = 4

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

func make_a_step(player_pos):
	for mesh in get_tree().get_nodes_in_group("debug_objects"):
		if mesh.get_surface_material(0).albedo_color == Color.purple:
			mesh.queue_free()
		
	var path = get_parent().get_parent().get_node("GridMap")\
	.find_path(translation, player_pos)
#	print("from (spider translation): ", translation)
#	print("to (player translation): ", player_pos)
	if path and len(path) > 1:
		var target_step = path[1]
		
		$Tween.interpolate_property(self, "translation", translation, \
		target_step, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
#	else:
#		print("no path or size 0")

func damage():
	animationPlayer.play("damage_shake")
