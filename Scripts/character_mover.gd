extends CharacterBody3D

var speed = 7
var relative_direction : Vector3
var is_navigating = false
var is_keying = false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player_camera: Camera3D = $"../Path3D/PathFollow3D/PlayerCamera"
@onready var path_3d: Path3D = $"../Path3D"

func _input(event: InputEvent) -> void:
	var key_direction : Vector3
	key_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	key_direction.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	key_direction = key_direction.normalized()
	if key_direction != Vector3.ZERO and not event.is_action_pressed("hold_movement"):
		is_keying = true
		relative_direction = key_direction.rotated(Vector3(0,1,0),path_3d.rotation.y)
		if navigation_agent_3d.is_navigation_finished() == false:
			stop_navigation()
	else:
		is_keying = false
		velocity = Vector3.ZERO
		
	if event.is_action_pressed("action") and not event.is_action_pressed("hold_movement"):
		is_keying = false
		if RayToMouse():
			navigation_agent_3d.target_position = RayToMouse()

func RayToMouse():
	var cam = player_camera
	var mouse_pos = get_viewport().get_mouse_position()
	var length = 100
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * length
	var space = get_world_3d().direct_space_state
	var rayquery = PhysicsRayQueryParameters3D.new()
	rayquery.from = from
	rayquery.to = to
	var result = space.intersect_ray(rayquery)
	if result.is_empty() == false:
		return space.intersect_ray(rayquery)["position"]

func stop_navigation():
	navigation_agent_3d.target_position = global_position

func _physics_process(_delta: float) -> void:
	if navigation_agent_3d.is_navigation_finished():
		is_navigating = false
		velocity = Vector3.ZERO
	else:
		var current_agent_position : Vector3 = global_position
		var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * speed
	if is_keying:
		velocity = relative_direction * speed
	if not Input.is_action_pressed("hold_movement"):
		move_and_slide()
		path_3d.global_position = global_position
		if velocity.length_squared() > 0:
			look_at(global_position + velocity)
	else:
		stop_navigation()
		if RayToMouse():
			look_at(RayToMouse())
	if rotation.x != 0:
		rotation.x = 0
	if rotation.z != 0:
		rotation.z = 0
