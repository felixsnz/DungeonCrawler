extends Sprite3D

export(int) var speed
var direction = Vector3.FORWARD
var damage
var bul = false

signal impacted(obj)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	direction = Vector3(cos(rotation.x), 0, sin(rotation.y))

func impact(obj):
	emit_signal("impacted", obj)
	queue_free()


func _process(delta):
	translation += direction * speed * delta
	


func _on_Area_body_entered(body):
	emit_signal("impacted", body)
	queue_free()
