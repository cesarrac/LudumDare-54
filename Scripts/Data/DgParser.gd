extends RefCounted
class_name DlgParser

static func parse_dialog_map(txt_lines : Array)->Dictionary:
	# list all tags
	var map : = {}
	var last_tag : = ""
	var tag_state : = 1
	print("PARSING DIALOG FILE...")
	for i in range(txt_lines.size()):
		var line : String = txt_lines[i]
		var type : int = parse_line_type(line)
		# Tries to Find next Hash tag
		if type == DlgObj.LINE_TYPES.HASH:
			# last tag is set and used as Key for map
			last_tag = parse_dialog_tag(line)
			if map.has(last_tag) == false:
				# a NEW TAG starts a new dialog map
				print("FOUND TAG '%s'" % last_tag)
				map[last_tag] = {}
				tag_state = 1
			else:
				tag_state += 1
			# fill TAG key with of TAG STATE value with new Array
			map[last_tag][tag_state] = []
		else:
			# None HASH lines now get added to map
			map[last_tag][tag_state].append(line)
			# These LINES are later read and parsed to show dialog
			# AND-OR run methods
	
	return map

static func get_state_count(txt_lines : Array)->int:
	var count : = 0
	for s in txt_lines:
		var t : int = parse_line_type(s)
		if t == DlgObj.LINE_TYPES.HASH:
			count += 1
	return count

static func parse_line_type(txt_line : String)->int:
	var s : String = txt_line.substr(0, 1)
	var symbol : int = DlgObj.LINE_TYPES.LINE
	match(s):
		"#":
			symbol = DlgObj.LINE_TYPES.HASH
		"$":
			symbol = DlgObj.LINE_TYPES.RESPONSE
		"[":
			symbol = DlgObj.LINE_TYPES.DEVENT
		_:
			symbol = DlgObj.LINE_TYPES.LINE
	return symbol

static func parse_state(txt_line : String)->int:
	var start : int = txt_line.find("_")
	if start < 0: return 0
	var n : String = txt_line.substr(start + 1, 1)
	return int(n)

static func parse_dialog_tag(hash_line : String)->String:
	var n : = "DIALOG"
	var start : int = hash_line.find("#")
	if start < 0: return ""
	var end : int = hash_line.find("_", start)
	if end < 0: end = hash_line.length()
	else: end -= 1
	if start >= 0 and end >= 0:
		n = hash_line.substr(start + 1, end)
	return n

static func parse_default(txt_line : String)->Dictionary:
	var parsed : = {"string" : "", "events" : []}
	var strng : = "DEFAULT DIALOG"
	strng = txt_line
	var display_string : = ""
	var events : = []
	var last_start : = strng.find("[")
	var last_end = strng.find("]", last_start)
	var i : = 0
	if last_start >=0:
		while(last_start >= 0):
			display_string += strng.substr(i, last_start - i)
			var event_map : Dictionary = parse_event(strng, last_start, last_end)
			if event_map.size() > 0:
				events.append(event_map)
			i = last_end + 1
			last_start = strng.find("[", last_end)
		
			if last_start >= 0:
				last_end = strng.find("]", last_start)
			
		display_string += strng.substr(i, strng.length() - last_end)
	else:
		display_string = strng
	parsed.string = display_string
	parsed.events = events
	parsed.is_prompt = false
	# verify is this is a question prompt
	parsed = _parse_prompt(parsed)
	return parsed

static func parse_responses(lines_post_prompt : Array)->Array:
	var responses : = []
	for i in range(lines_post_prompt.size()):
		var string : String = lines_post_prompt[i]
		if string.begins_with("$") == false:
			break
		# get tag from response
		var colon_index : int = string.find(":", 1)
		var rsp_tag : String = string.substr(1, colon_index - 1)
		# get response text
		var rsp_txt : String = string.substr(colon_index + 1, string.length() - colon_index)
		responses.append({
			"tag" : rsp_tag,
			"text" : rsp_txt
		})
	return responses

static func parse_event(strng : String, last_start : int, last_end : int)->Dictionary:
	var evt_name : = strng.substr(last_start + 1, (last_end - last_start) - 1)
	var v_start : int = evt_name.find("(")
	var v_end : int = evt_name.find(")")
	var values : = []
	if v_start > 0 and v_end > 0:
		var value_str : = evt_name.substr(v_start + 1, (v_end - v_start) - 1)
		evt_name = evt_name.erase(v_start, (v_end - v_start) + 1)
		if value_str.find(",", 1) > 0:
			values = value_str.split(",")
		else:
			values.append(value_str)
		print("values parsed from %s are %s" % [strng, values])
	var evt : = {
		"name" : evt_name,
		"values" : values,
		"start_index" : last_start,
		"end_index" : last_end
	}
	
	return evt

static func parse_events_raw(strng : String)->Array:
	var last_start : = strng.find("[")
	var last_end = strng.find("]", last_start)
	var events : = []
	while(last_start >= 0):
		events.append(parse_event(strng, last_start, last_end))
		last_start = strng.find("[", last_end)
		last_end = strng.find("]", last_start)
	return events

static func parse_speaker_name(first_line : String)->String:
	var n : = "Speaker X"
	var type : int = parse_line_type(first_line)
	if type != DlgObj.LINE_TYPES.HASH: return n
	n = parse_dialog_tag(first_line)
	return n

static func clean_up_marked(strng : String)->String:
	var last_start : int = strng.find("_")
	while(last_start >= 0):
		strng.erase(last_start, 1)
		last_start = strng.find("_")
	return strng
	
static func _parse_prompt(parsed_line : Dictionary)->Dictionary:
	var line : String = parsed_line.string
	if line.ends_with(":"):
		var clean_line : String = line.substr(0, line.length() - 1)
		parsed_line.string = clean_line
		parsed_line.is_prompt = true
		print("found PROMPT line!")
	return parsed_line
