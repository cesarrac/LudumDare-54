extends CanvasLayer
class_name UIMgr

@export var text_label : RichTextLabel
@export var opt_box : VBoxContainer
@export var cont_btn : TextureButton
@export var from_lbl : Label
@export var nxt_ch_btn : Button
@onready var resp_scn = preload("res://Scenes/UI/diag_response.tscn")

func _ready():
	EventMgr.sub_listener("new_speaker", new_speaker.bind())
	EventMgr.sub_listener("display_next_line", Callable(self, "fill_dialog"))
	EventMgr.sub_listener("end_dialog", Callable(self, "end_dialog"))
	EventMgr.sub_listener("new_responses", Callable(self, "add_opts"))
	cont_btn.pressed.connect(_continue_pressed.bind())
	
func new_speaker(n : String)->void:
	$DialogPanel.show()
	from_lbl.text = n
	
func fill_dialog(d_str : String)->void:
	print("filling dialog!")
	text_label.clear()
	text_label.append_text(d_str)

func add_opts(responses : Array)->void:
	if responses.size() <= 0: return
	_clear_opts()
	for i in range(responses.size()):
		var map : Dictionary = responses[i]
		var r : = resp_scn.instantiate()
		opt_box.add_child(r)
		r.text = map.text
		r.get_child(0).pressed.connect(_response_pressed.bind(map.tag))
	toggle_cont_btn(false)

func end_dialog()->void:
	text_label.clear()
	_clear_opts()
	$DialogPanel.hide()

func toggle_cont_btn(show : bool)->void:
	if show: cont_btn.show()
	else: cont_btn.hide()

func toggle_nxt_ch_btn()->void:
	if nxt_ch_btn.visible:
		nxt_ch_btn.hide()
		return
	nxt_ch_btn.show()
	
func _continue_pressed()->void:
	print('continue!!')
	EventMgr.fire_event("continue_pressed")

func _response_pressed(tag : String)->void:
	print("response was pressed!")
	_clear_opts()
	toggle_cont_btn(true)
	# fire event!
	EventMgr.fire_event("jump_to_tag", [tag, 1])

func _clear_opts()->void:
	if opt_box.get_child_count() > 0:
		var chs = opt_box.get_children()
		for r in chs:
			r.queue_free()


func _on_nxt_chapter_btn_pressed() -> void:
	toggle_nxt_ch_btn()
	EventMgr.fire_event(
		"nxt_chapter_requested"
	)


func _on_endDlgBtn_pressed() -> void:
	EventMgr.fire_event("cancel_dialog")
