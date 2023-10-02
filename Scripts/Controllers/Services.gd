extends Node2D

@export var diag_mgr : DiagMgr
@export var camera : Camera2DCtr
@export var map : MapCtr
@export var chapters_holder : Node2D

var move_input : Vector2
var cur_chapter : = -1


func _ready():
	nxt_chapter()
	EventMgr.sub_listener(
		"dialog_selected", on_diag_selected.bind()
	)
	EventMgr.sub_listener(
		"continue_pressed", on_continue_diag.bind()
	)
	EventMgr.sub_listener(
		"jump_to_tag", diag_mgr.jump_to_tag.bind()
	)

func nxt_chapter()->void:
	var last : = cur_chapter
	cur_chapter += 1
	var chapters : Array = chapters_holder.get_children()
	if cur_chapter >= chapters.size():
		print("story finished!")
		return
	if last >= 0:
		chapters[last].end_chapter()
	var cam_pos : Vector2 = chapters[cur_chapter].start_chapter()
	camera.go_to(cam_pos)

func on_diag_selected(trigger : DialogTrigger, path : String)->void:
	if diag_mgr.cur_dlg_scn != null: return
	if diag_mgr.load_dialog(path):
		trigger.toggle_trigger()
	

func on_continue_diag()->void:
	print("continue dialog pressed!")
	diag_mgr.advance_dlg()

func _process(delta):
	move_input = SWTools.get_move_2d()
	camera.move(move_input, delta)

func _unhandled_input(event):
	if event.is_action_pressed("test"):
		nxt_chapter()
