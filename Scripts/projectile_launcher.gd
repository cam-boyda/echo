extends Marker3D
class_name ProjectileLauncher

var is_active = true
var cooldown_timer : Timer = Timer.new()
var attack_timer : Timer = Timer.new()
var target_point
var ignore_hurt_box = []

const PROJECTILE = preload("res://Module Scenes/projectile.tscn")

func _ready() -> void:
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout",cooldown_timeout)
	cooldown_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout",attack_timeout)
	attack_timer.one_shot = true

func attack_start(target: Vector3, duration : float = 0.3, cooldown : float = 1.5):
	if is_active and target:
		cooldown_timer.wait_time = cooldown
		target_point = target
		is_active = false
		attack_timer.start(duration)

func attack_timeout():
	var new_projectile = PROJECTILE.instantiate()
	add_child(new_projectile)
	new_projectile.global_position = global_position
	new_projectile.target_point = target_point
	new_projectile.top_level = true
	is_active = false
	cooldown_timer.start()

func cooldown_timeout():
	is_active = true

func monitor_hits(hurt_box):
	if hurt_box is HurtBox and not ignore_hurt_box.has(hurt_box):
		print("projectile launched")
