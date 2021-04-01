extends Spatial

onready var animationPlayer = $AnimationPlayer
onready var rayCast = $RayCast
onready var stats = $Stats

export(bool) var visible_path

enum STATES {
	IDLE,
	CHASING,
	WANDERING
}

var state = STATES.IDLE

func _ready():
	pass

func _physics_process(_delta):
	look_at_player()
	

func make_a_step(player_pos):
	clear_path()
	var path = Global.grid_map.find_path(translation, player_pos)
	if path and len(path) > 1:
		var target_step = path[1]
		$Tween.interpolate_property(self, "translation", translation, \
		target_step, .5, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		if visible_path:
			Global.grid_map.generate_path(path)

func damage(amount):
	animationPlayer.play("damage_shake")
	stats.health -= amount

func clear_path():
	if visible_path:
		for mesh in get_tree().get_nodes_in_group("debug_objects"):
			if mesh.get_surface_material(0).albedo_color == Color.purple:
				mesh.queue_free()

func look_at_player():
	var player = Global.player
	if player != null:
		look_at(player.global_transform.origin, Vector3.UP)

func _on_Stats_health_changed(value):
	pass # Replace with function body.


func _on_Stats_no_health():
	queue_free()
