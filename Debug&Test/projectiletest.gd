extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var vel = Vector3.ZERO
var direction = Vector3.ZERO
var speed = .5
var damage
var not_impacted = true

signal impacted(obj)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel = direction * speed
	var collision = move_and_collide(vel)
	if collision and not_impacted:
		not_impacted = false
		var collider = collision.collider
		emit_signal("impacted", collider)
		$AudioStreamPlayer3D.play()
		yield($AudioStreamPlayer3D, "finished")
		queue_free()
		
