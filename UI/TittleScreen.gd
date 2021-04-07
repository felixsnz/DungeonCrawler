extends Control


const SelecSound = preload("res://Assets/Sounds/8bit-sounds/Select 1.wav")
const ClickSound = preload("res://Assets/Sounds/8bit-sounds/Confirm 1.wav")

onready var streamPlayer = $AudioStreamPlayer

var can_focus = true

func _ready():
	$ColorRect/AnimationPlayer.play_backwards("fade_in")
	$MenuOptions/NewGame.grab_focus()
	
	for btn in $MenuOptions.get_children():
		btn.connect("focus_entered", self, "_on_btn_selected")
		btn.connect("mouse_entered", self, "_on_btn_selected")
		btn.connect("button_down", self, "_on_btn_clicked")

func _on_btn_selected():
	if can_focus:
		streamPlayer.stream = SelecSound
		streamPlayer.play()

func _on_btn_clicked():
	streamPlayer.stream = ClickSound
	streamPlayer.play()


func _on_Quit_Game_button_down():
	disable_all()
	yield(streamPlayer, "finished")
	get_tree().quit()

func _on_NewGame_button_down():
	
	disable_all()
	$ColorRect/AnimationPlayer.play("fade_in")
	yield($ColorRect/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Game.tscn")

func disable_all():
	can_focus = false
	for btn in $MenuOptions.get_children():
		btn.disabled = true

func enable_all():
	can_focus = true
	for btn in $MenuOptions.get_children():
		btn.disabled = false
	
	

func _on_Options_button_down():
	disable_all()
	$Options.popup()


func _on_Options_popup_hide():
	enable_all()

