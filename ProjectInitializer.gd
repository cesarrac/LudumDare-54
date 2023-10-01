extends Node2D

@export var folder_names : Array


func _ready() -> void:
	if folder_names.size() <= 0:
		print("Folder names NOT DEFINED! error returning...")
		return
	print("Creating main folders ...")
	var total_made : = 0
	for f in folder_names:
		if make_folder(
			f, "res://"
		) != OK:
			print("Failed to make folder %s" % f)
		total_made += 1
	print("Made %s out of %s folders!" % [total_made, folder_names.size()])

func make_folder(folder_name : String, dir_path : String)->int:
	var full_path : = dir_path + folder_name
	if FileAccess.file_exists(full_path): return FAILED
	# make dir
	return DirAccess.make_dir_absolute(full_path)
