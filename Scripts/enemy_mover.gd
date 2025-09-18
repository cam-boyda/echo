extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer

var interest_vector
var interest_array : Array #scalars
var avoidance_array : Array #scalars
var context_array : Array #scalars
var avoidance_buffer = 4
var steering_sharpness = 0.4
var speed = 3
var target

const VECTOR_ARRAY = [Vector3(0,0,-1),Vector3(0.70710,0,-0.707107),Vector3(1,0,0),Vector3(0.70710,0,0.707107),
Vector3(0,0,1),Vector3(-0.70710,0,0.707107),Vector3(-1,0,0),Vector3(-0.70710,0,0.707107)]

func update_interest_array(i_point : Vector3):
	var vec_toward_interest = (to_local(global_position)+to_local(i_point)).normalized()
	vec_toward_interest.y = 0
	var result : Array = []
	for vec in VECTOR_ARRAY:
		result.append(vec_toward_interest.dot(vec))
	interest_array = result

func update_avoidance_array():
	var result : Array = []
	for vec in VECTOR_ARRAY:
		var direction = cast_array(global_position,vec*avoidance_buffer)
		if direction:
			result.append(5)
		else:
			result.append(0)
	avoidance_array = result

func update_context_array():
	var result : Array = []
	for i in interest_array.size():
		var context = interest_array[i] - avoidance_array[i]
		result.append(context)
	context_array = result

func cast_array(from,to):
	var space = get_world_3d().direct_space_state
	var rayquery = PhysicsRayQueryParameters3D.create(from,to)
	var result = space.intersect_ray(rayquery)
	if result.keys().is_empty() == false:
		return result

func steering_force(desired_v,current_v):
	return (desired_v - current_v) * steering_sharpness * Vector3(1,0,1)

func get_desired_velocity():
	return VECTOR_ARRAY[context_array.find(context_array.max())]

func update_nav_target():
	if target:
		navigation_agent_3d.target_position = target.global_position
		update_interest_array(target.global_position)
		update_avoidance_array()
		update_context_array()

func stop_nav():
	navigation_agent_3d.target_position = global_position

func _physics_process(delta: float) -> void:
	if navigation_agent_3d.is_navigation_finished():
		timer.stop()
		return
	if timer.is_stopped():
		timer.start()
	var current_agent_position : Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var current_velocity = (current_agent_position.direction_to(next_path_position) * speed) * Vector3(1,0,1)
	velocity = current_velocity
	velocity = velocity + steering_force(get_desired_velocity() ,current_velocity * delta)
	move_and_slide()


func _on_timer_timeout() -> void:
	update_nav_target()
