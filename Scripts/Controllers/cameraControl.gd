extends Node2D
class_name Camera2DCtr

@onready var camera : Camera2D = $Camera2D

const MAX_ZOOM : = 4
const MIN_ZOOM : = 0.25
@export_range(100.0, 1000.0, 25.0) var SCROLL_SPEED : = 250.0

func zoom(modifier : int)->void:
	if modifier < 0: 	# zoom in
		camera.zoom = Vector2(
			clamp(camera.zoom.x - 0.5, MIN_ZOOM, MAX_ZOOM),
			clamp(camera.zoom.y - 0.5, MIN_ZOOM, MAX_ZOOM)
		)
		return
						# zoom out
	camera.zoom = Vector2(
		clamp(camera.zoom.x + 0.5, MIN_ZOOM, MAX_ZOOM),
		clamp(camera.zoom.y + 0.5, MIN_ZOOM, MAX_ZOOM)
	)

func move(
	input_dir : Vector2,
	delta : float
)->void:
	var direction : Vector2 = input_dir.normalized()
	position += direction * SCROLL_SPEED * delta

func go_to(cam_pos : Vector2)->void:
	position = cam_pos
