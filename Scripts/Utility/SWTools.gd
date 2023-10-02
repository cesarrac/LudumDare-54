extends Node
class_name SWTools
# Version 2.0 (5-30-2023)

# ---	MATH
static func get_shortst_angle_dist(from, to)->float:
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

# ---	STEERING
static func seek(
	character_position : Vector2,
	target_position : Vector2
)->Vector2:
	var direction : = target_position - character_position
	direction = direction.normalized()
	return direction

static func flee(
	character_position : Vector2,
	threat_position : Vector2
)->Vector2:
	return seek(
		threat_position, character_position
	)

static func follow(
	velocity : Vector2,
	body_position : Vector2,
	target_position : Vector2,
	max_speed : = 100.0,
	mass : = 1.0
) -> Vector2:
	var desired_velocity : = (target_position - body_position).normalized() * max_speed
	var steering = (desired_velocity - velocity) / mass
	return velocity + steering

static func predict_next_pos(
	velocity : Vector2,
	character_position : Vector2,
	target_position : Vector2,
	target_velocity : Vector2,
	max_speed : = 100.0,
	max_prediction : = 2.0
)->Vector2:
	var direction : = target_position - character_position
	var distance : = direction.length()
	var prediction : = 0.0
	var speed : = velocity.length()
	if speed <= distance / max_prediction:
		prediction = max_prediction
	else:
		prediction = distance / speed
	var new_seek_target = target_position + (target_velocity * prediction)
	return new_seek_target

# ---	ARRAY SORTING
static func sort_ascending(obj_a, obj_b)->bool:
	if obj_a < obj_b:
		return true
	return false

static func sort_descending(obj_a, obj_b)->bool:
	if obj_a > obj_b:
		return true
	return false

# ---	DEBUGGING
static func show_text_2D(
	node : Node2D,
	global_text_pos : Vector2,
	text : String,
	color : = Color.SNOW,
	duration : = -1
)->Label:
	var label = Label.new()
	node.add_child(label)
	label.set_global_position(global_text_pos)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set("custom_colors/font_color", color)
	if duration > 0:
		var timer : = Timer.new()
		label.add_child(timer)
		var callable = Callable(label, "queue_free")
		timer.timeout.connect(callable)
		timer.wait_time = duration
		timer.one_shot = true
		timer.start()
	return label

static func show_text_3D(
	scene_tree : SceneTree,
	global_position : Vector3, 
	text : String,
	color : = Color.SNOW,
	duration : = -1
)->Label3D:
	var label = Label3D.new()
	scene_tree.current_scene.add_child(label)
	label.modulate = color
	label.global_position = global_position
	label.text = text
	if duration > 0:
		var timer : = Timer.new()
		label.add_child(timer)
		var callable = Callable(label, "queue_free")
		timer.timeout.connect(callable)
		timer.wait_time = duration
		timer.one_shot = true
		timer.start()
	return label

static func show_grid_3d(
	draw_node : Node3D,
	global_points : Array,
	color : Color
)->Node3D:
	if global_points.size() <= 0: return
	var mesh = ImmediateMesh.new()
#	draw_node.add_child(mesh)
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for p in global_points:
		mesh.surface_add_vertex(p)
	mesh.surface_end()
	var mesh_instance : = MeshInstance3D.new()
	draw_node.add_child(mesh_instance)
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow =GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return mesh_instance

#--- INPUT
static func get_move_2d()->Vector2:
	return Input.get_vector("left", "right", "up", "down")

static func get_move_3d()->Vector3:
	var vector = Input.get_vector("left", "right", "up", "down")
	return Vector3(vector.x, 0, vector.y)

static func get_mouse_3d(
	mouse2d : Vector2,
	camera : Camera3D,
	distance : = 10000.0
)->Vector3:
	var ray_start = camera.project_ray_origin(mouse2d)
	var ray_end = ray_start + camera.project_ray_normal(mouse2d) * distance
	var ground_plane : = Plane(Vector3.UP, 0)
	var position = ground_plane.intersects_ray(ray_start, ray_end)
	return position if position != null else ray_end

#--- FILE HANDLING
static func load_txt_file(full_path : String)->Array:
	var lines : = []
	var file : = FileAccess.open(full_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var line : String = file.get_line()
		lines.append(line)

	return lines
