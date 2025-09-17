extends Node3D
class_name Projectile

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var explosion_mesh: MeshInstance3D = $explosion_mesh
@onready var explosion_detection: Area3D = $explosion_mesh/explosion_detection
@onready var contact_detection: Area3D = $MeshInstance3D/contact_detection


var fire_point
var target_point
var position_t = 0.0

var is_exploding = false
var exploding_t = 0.0
var exploding_time = 0.5

func _ready() -> void:
	fire_point = global_position
	
func bezier_path_up_down(origin: Vector3, target: Vector3, t: float):
	var mid_point = ((origin + target)/2) + Vector3(0,4,0)
	var q0 = origin.lerp(mid_point, t)
	var q1 = mid_point.lerp(target, t)
	var result = q0.lerp(q1, t)
	return result

func _physics_process(delta: float) -> void:
	if target_point and not is_exploding:
		position_t += delta
		global_position = bezier_path_up_down(fire_point,target_point,position_t)
		if not contact_detection.get_overlapping_bodies().is_empty():
			explode()
		if global_position.distance_to(target_point) <= 0.1 or position_t >= 10:
			explode()
	if is_exploding:
		exploding_t += delta
		if exploding_t >= exploding_time:
			queue_free()

func explode():
	explosion_mesh.visible = true
	mesh_instance_3d.visible = false
	is_exploding = true
	explosion_detection.monitoring = true
	var all_areas = explosion_detection.get_overlapping_areas()
	for area in all_areas:
		if area is HurtBox:
			print("explosion hit")
