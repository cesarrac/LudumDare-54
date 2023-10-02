extends DialogTrigger

@export_file("*.tres") var character_data_path : String
@onready var character_data : CharacterData = load(character_data_path)

func _ready():
	if !character_data: return
	self.self_modulate = character_data.character_color
	$name_label.text = character_data.name
