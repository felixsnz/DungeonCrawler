extends HScrollBar

func _on_HScrollBar_scrolling():
	var dbvalue = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(get_node("../").name), dbvalue)

func _on_HScrollBar_value_changed(_value):
	get_node("../AudioStreamPlayer").play()
