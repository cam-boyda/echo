extends Node

var can_attack = false
var is_melee = false
var is_hit_scan = false
var is_projectile = false

@onready var hit_box: HitBox = $"../CharacterBody3D/HitBox"
@onready var hurt_box: Area3D = $"../CharacterBody3D/HurtBox"
@onready var hit_scan: HitScan = $"../CharacterBody3D/HitScan"
@onready var projectile_launcher: ProjectileLauncher = $"../CharacterBody3D/ProjectileLauncher"
@onready var player_camera: Camera3D = $"../Path3D/PathFollow3D/PlayerCamera"
@onready var player: CharacterBody3D = $"../CharacterBody3D"



func _ready() -> void:
	hit_box.ignore_hurt_box.append(hurt_box)
	hit_scan.add_exception(hurt_box)
	hit_scan.add_exception(hit_box)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("hold_movement"):
		can_attack = true
	else:
		can_attack = false
	if can_attack and event.is_action_pressed("action"):
		if is_melee:
			hit_box.attack_start()
		if is_hit_scan:
			hit_scan.attack_start()
		if is_projectile:
			if RayToMouse():
				projectile_launcher.attack_start(RayToMouse())

func RayToMouse():
	var cam = player_camera
	var mouse_pos = get_viewport().get_mouse_position()
	var length = 100
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * length
	var space = player.get_world_3d().direct_space_state
	var rayquery = PhysicsRayQueryParameters3D.new()
	rayquery.from = from
	rayquery.to = to
	var result = space.intersect_ray(rayquery)
	if result.is_empty() == false:
		return space.intersect_ray(rayquery)["position"]

func use_weapon(weapon):
	is_melee = false
	is_hit_scan = false
	is_projectile = false
	match weapon:
		"melee":
			is_melee = true
		"hit_scan":
			is_hit_scan = true
		"projectile":
			is_projectile = true
