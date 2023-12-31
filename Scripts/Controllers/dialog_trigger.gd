extends Sprite2D
class_name DialogTrigger

@export_file("*.txt") var dialog_path : String
@export var bit_tick_tag : = ""
var _triggerable : = false
signal pressed

func toggle_trigger()->void:
	_triggerable = !_triggerable
	if !_triggerable:
		modulate = Color.DIM_GRAY
	else:
		modulate = Color.WHITE
		if bit_tick_tag.length() > 0:
			EventMgr.fire_event(
				"bit_trigger_set", [bit_tick_tag]
			)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if !_triggerable: return
	
	if event.is_action_pressed("M0"):
#		SWTools.show_text_2D(
#			self,
#			global_position,
#			'clicked on %s' % name,
#			Color.BLUE,
#			2.0
#		)
		pressed.emit()
		if dialog_path.length() <= 0: return
		EventMgr.fire_event(
			"dialog_selected",
			[self, dialog_path]
		)
