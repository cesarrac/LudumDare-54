extends RefCounted
class_name DlgObj

enum LINE_TYPES {
	HASH,
	LINE,
	DEVENT,
	RESPONSE
}

var txt_lines : = []
var index : = -1
var dg_map : Dictionary
var cur_tag : = ""
var cur_state : = 0

func _init(map : Dictionary)->void:
	dg_map = map
	jump_to(get_tag_at(0), 0)
	
func get_tag_at(key_index : int)->String:
	var tags : = dg_map.keys()
	if key_index < 0: return tags.front()
	elif key_index >= tags.size(): return tags.back()
	return tags[key_index]

func jump_to(tag : String, state : int)->void:
	if dg_map.has(tag) == false:
		print("WDiagObj has no dialog tagged '%s' - setting to default" % tag)
		return
	if dg_map[tag].has(state) == false:
		state = dg_map[tag].keys().front()
	cur_state = state
	cur_tag = tag
	txt_lines = dg_map[cur_tag][cur_state].duplicate()
	index = -1

func advance_line()->bool:
	if txt_lines.size() <= 0: return false
	index += 1
	if index >= txt_lines.size():
		if advance_state() == false:
			index = 0
			txt_lines.clear()
			return false
		jump_to(cur_tag, cur_state)
		advance_line()
	return true

func get_line(i = index)->String:
	return txt_lines[i]

func get_next_lines()->Array:
	var next : = []
	if index + 1 >= txt_lines.size(): return []
	for i in range(index + 1, txt_lines.size()):
		next.append(txt_lines[i])
	return next

func advance_state()->bool:
	var new_state : = cur_state + 1
	if dg_map[cur_tag].has(new_state) == false:
		txt_lines = ["DIALOG ENDED"]
		cur_state = 1
		return false
	cur_state = new_state
	print("dialog %s now at state %s" % [cur_tag, cur_state])
	return true
