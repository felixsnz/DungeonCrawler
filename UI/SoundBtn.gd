extends Button


func _pressed():
	var node = get_node("../Slider")
	
	if(name == "Minus"):
		node.set_value(node.get_value() - node.step)
	else:
		node.set_value(node.get_value() + node.step)
	
	var dbvalue = node.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(get_node("../").name), dbvalue)
	get_node("../AudioStreamPlayer").play()
