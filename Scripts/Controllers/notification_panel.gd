extends Control

@export var header_lbl : Label
@export var content_lbl : Label

func _ready() -> void:
	EventMgr.sub_listener(
		"notify", notify.bind()
	)
	
func notify(title : String, msg : String)->void:
	show()
	header_lbl.text = title
	content_lbl.text = msg


func _on_close_pressed() -> void:
	hide()
