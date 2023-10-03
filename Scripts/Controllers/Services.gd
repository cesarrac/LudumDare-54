extends Node2D

@export var diag_mgr : DiagMgr
@export var camera : Camera2DCtr
@export var map : MapCtr
@export var chapters_holder : Node2D
@export var player_journal : PlayerJournal
@export var ui_mgr : UIMgr
var move_input : Vector2


func _ready():
	EventMgr.sub_listener(
		"dialog_selected", on_diag_selected.bind()
	)
	EventMgr.sub_listener(
		"continue_pressed", on_continue_diag.bind()
	)
	EventMgr.sub_listener(
		"jump_to_tag", diag_mgr.jump_to_tag.bind()
	)
	EventMgr.sub_listener(
		"BITCHECK", _on_story_bitcheck.bind()
	)
	EventMgr.sub_listener(
		"ADDBIT", _on_new_bit.bind()
	)
	EventMgr.sub_listener(
		"TICKBIT", _on_tick_bit.bind()
	)
	EventMgr.sub_listener(
		"bit_trigger_set", _on_bit_trigger_set.bind()
	)
	EventMgr.sub_listener(
		"chapter_triggers_completed", _on_ch_triggers_set.bind()
	)
	EventMgr.sub_listener(
		"nxt_chapter_requested", nxt_chapter.bind()
	)
	EventMgr.sub_listener(
		"cancel_dialog", _on_cancel_diag.bind()
	)

func nxt_chapter()->void:
	var last : = player_journal.cur_chapter
	player_journal.goto_chapter(last + 1)
	var chapters : Array = chapters_holder.get_children()
	if player_journal.cur_chapter >= chapters.size():
		print("story finished!")
		return
	if last >= 0:
		chapters[last].end_chapter()
	var cam_pos : Vector2 = chapters[player_journal.cur_chapter].start_chapter()
	camera.go_to(cam_pos)

func on_diag_selected(trigger : DialogTrigger, path : String)->void:
	if diag_mgr.cur_dlg_scn != null: return
	if diag_mgr.load_dialog(path):
		trigger.toggle_trigger()
	

func on_continue_diag()->void:
	print("continue dialog pressed!")
	diag_mgr.advance_dlg()

func _on_cancel_diag()->void:
	diag_mgr.end_dlg()

func _on_story_bitcheck(
	bit : String,
	jump_tag_true : String,
	jump_tag_false : String,
	jump_tag_null : String
)->void:
	print("BITCHECK!")
	if player_journal.has_bit_tagged(bit) == false:
		if jump_tag_null.length() > 0:
			diag_mgr.jump_to_tag(jump_tag_null)
		else:
			diag_mgr.advance_dlg()
		return
	if player_journal.has_bit_completed(bit) == true:
		diag_mgr.jump_to_tag(jump_tag_true)
	else:
		print("bit check failed...")
		if jump_tag_false.length() > 0:
			diag_mgr.jump_to_tag(jump_tag_false)
			return
		diag_mgr.advance_dlg()
	
func _on_new_bit(bit_tag : String)->void:
	print('adding bit %s' % bit_tag)
	var t
	player_journal.on_new_bit(bit_tag)
	diag_mgr.advance_dlg()

func _on_bit_trigger_set(tag : String)->void:
	player_journal.edit_bit(tag)

func _on_tick_bit(tag : String)->void:
	print('TICK!')
	diag_mgr.advance_dlg()
	if player_journal.tick_bit(tag) == false:
		return
	# notify player that quest is completed
	EventMgr.fire_event("notify", ["Task Completed!", "%s task was completed" % tag])

func _on_ch_triggers_set()->void:
	print("chapter complete!")
	ui_mgr.toggle_nxt_ch_btn()

func _process(delta):
	move_input = SWTools.get_move_2d()
	camera.move(move_input, delta)

func _unhandled_input(event):
	if event.is_action_pressed("test"):
		nxt_chapter()
