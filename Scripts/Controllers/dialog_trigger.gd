extends Sprite2D
class_name DialogTrigger

@export_file("*.txt") var dialog_path : String
var _triggerable : = false

func toggle_trigger()->void:
	_triggerable = !_triggerable
	if !_triggerable:
		modulate = Color.DIM_GRAY
	else:
		modulate = Color.WHITE

func _on_area_2d_input_event(viewport, event, shape_idx):
	if !_triggerable: return
	
	if event.is_action_pressed("M0"):
		SWTools.show_text_2D(
			self,
			global_position,
			'clicked on %s' % name,
			Color.BLUE,
			2.0
		)
		if dialog_path.length() <= 0: return
		EventMgr.fire_event(
			"dialog_selected",
			[self, dialog_path]
		)
