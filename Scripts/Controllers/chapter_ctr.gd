extends Node2D

@onready var triggers = get_children()

var pressed_count : = 0

func _ready() -> void:
	triggers.remove_at(0)
	for i in range(triggers.size()):
		triggers[i].pressed.connect(_tri_pressed.bind())

func start_chapter()->Vector2:
	show()
	pressed_count = 0
	for i in range(triggers.size()):
		triggers[i].toggle_trigger()
	return $start.global_position

func end_chapter()->void:
	hide()
	for i in range(triggers.size()):
		triggers[i].toggle_trigger()

func _tri_pressed()->void:
	pressed_count += 1
	
	print("%s triggers pressed, %s left" % [pressed_count, triggers.size()])
	if pressed_count >= triggers.size():
		EventMgr.fire_event(
			"chapter_triggers_completed"
		)
