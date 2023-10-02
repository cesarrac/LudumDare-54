extends Node2D
class_name DiagMgr

var cur_dlg_scn : DlgObj

func load_dialog(dialog_path : String)->bool:
	var txts : Array = SWTools.load_txt_file(dialog_path)
	if txts.size() <= 0:
		print("FOUND NO TEXT!")
		return false
	var map : Dictionary = DlgParser.parse_dialog_map(txts)
	if !map or map.size() <= 0: return false
	cur_dlg_scn = DlgObj.new(map)
	advance_dlg()
	EventMgr.fire_event(
		"new_speaker", 
		[DlgParser.parse_speaker_name(txts.front())]
	)
	return true

func advance_dlg()->void:
	if !cur_dlg_scn: return
	if cur_dlg_scn.advance_line() == false:
		end_dlg()
		return
	var raw_txt : String = cur_dlg_scn.get_line()
	if raw_txt.length() <= 0:
		end_dlg()
		return
	_parse_line(raw_txt)

func _parse_line(raw_txt : String)->void:
	print("parsing %s" % raw_txt)
	# parse line type
	var line_type : int = DlgParser.parse_line_type(raw_txt)
	# run by line type
	match(line_type):
		DlgObj.LINE_TYPES.LINE:
			print("line type is text line")
			var parsed : Dictionary = DlgParser.parse_default(raw_txt)
			_output_to_ui(parsed.string, parsed.events)
			if parsed.is_prompt:
				var responses : Array = DlgParser.parse_responses(
					cur_dlg_scn.get_next_lines()
				)
				if responses.size() > 0:
					EventMgr.fire_event(
						"new_responses", [responses])
		DlgObj.LINE_TYPES.DEVENT:
			print("line type is event")
			# parse and run event
			var events : Array = DlgParser.parse_events_raw(raw_txt)
			if events.size() <= 0: return
			for i in range(events.size()):
				# check for jump event
				if events[i].name.begins_with("#"):
					var tag : String = DlgParser.parse_dialog_tag(events[i].name)
					if tag.length() > 0:
						var state : = 1
						if events[i].values.size() > 0:
							state = int(events[i].values.front())
						jump_to_tag(tag, state)
					return
				# or  fire event
				_run_events(events)
					

func _output_to_ui(marked_txt : String, events : = [])->void:
	var display_txt : String = DlgParser.clean_up_marked(marked_txt)
	print("display text = %s" % display_txt)
	EventMgr.fire_event("display_next_line", [display_txt])

func _run_events(raw_events : Array)->void:
	print("running events!")
	for i in range(raw_events.size()):
		var parsed_event : Dictionary = raw_events[i]
		# fire event
		EventMgr.fire_event(
			parsed_event.name,
			parsed_event.values
		)

func jump_to_tag(tag : String, state : = 1)->void:
	print("jumping dialog to tag %s" % tag)
	cur_dlg_scn.jump_to(tag, state)
	advance_dlg()

func end_dlg()->void:
	print("calling END DIALOG!")
	if !cur_dlg_scn: return
	EventMgr.fire_event("end_dialog")
	cur_dlg_scn = null
