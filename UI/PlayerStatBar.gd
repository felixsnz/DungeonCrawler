extends Control

var maximum = 100
var maximun_withe = 100
var current_health = 0
var values_scalar = 100

enum transition_types {
	TRANS_LINEAR,
	TRANS_LINEAR,
	TRANS_QUINT,
	TRANS_QUART,
	TRANS_QUAD,
	TRANS_EXPO,
	TRANS_ELASTIC,
	TRANS_CUBIC,
	TRANS_CIRC,
	TRANS_BOUNCE,
	TRANS_BACK
}

onready var ValueBar = $ValueBar
onready var whiteBar = $WhiteBar
onready var countContainer = $Count
onready var countIndicator = $Count/Label
onready var animationPlayer = $AnimationPlayer

export(transition_types) var trans_type

signal health_changued



func initialize(max_val):
	ValueBar.max_value = max_val * values_scalar
	maximum = max_val * values_scalar
	maximun_withe = max_val * values_scalar
	whiteBar.max_value = max_val * values_scalar


func update_bar(new_health):
	animate_value(current_health, new_health * values_scalar)
	update_count_text(new_health)
	current_health = new_health * values_scalar

func animate_value(start, end):
	$Tween.interpolate_property(ValueBar, "value", ValueBar.value, \
	end, .5, trans_type, Tween.EASE_OUT)
	$Tween.interpolate_property(whiteBar, "value", whiteBar.value, \
	end, .7, Tween.TRANS_LINEAR)
	$Tween.interpolate_method(self, "update_count_text", start, \
	end, .5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	if end < start:
		pass
#		animationPlayer.play("NumberShake")
		emit_signal("health_changued", null)
		
		
func update_value(value):
	animate_value(current_health, value * values_scalar)
	update_count_text(value)
	current_health = value * values_scalar

func update_count_text(value):
	countIndicator.text = str(clamp(round(value / values_scalar), 0, maximum)) + '/' + str(maximum/values_scalar) + "Hp"
