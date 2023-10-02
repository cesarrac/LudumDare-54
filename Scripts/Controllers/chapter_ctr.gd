extends Node2D

func start_chapter()->Vector2:
	show()
	var children : = get_children()
	for c in children:
		if c.name == "start": continue
		# toggle dialog trigger
		c.toggle_trigger()
	return $start.global_position

func end_chapter()->void:
	hide()
	var children : = get_children()
	for c in children:
		if c.name == "start": continue
		# toggle dialog trigger
		c.toggle_trigger()
