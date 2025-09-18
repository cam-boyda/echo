extends Area3D
class_name HitBox

var is_active = true
var cooldown_timer : Timer = Timer.new()
var attack_timer : Timer = Timer.new()
var ignore_hurt_box = []
var damage = 1

@onready var debug: CSGPolygon3D = $debug


func _ready() -> void:
	debug.material_override.albedo_color = Color.ORANGE
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout",cooldown_timeout)
	cooldown_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout",attack_timeout)
	attack_timer.one_shot = true
	monitoring = false
	monitorable = false
	connect("area_entered",monitor_hits)

func attack_start(duration : float = 0.3, cooldown : float = 0.5):
	if is_active:
		debug.material_override.albedo_color = Color.ORANGE
		monitoring = true
		debug.visible = true
		cooldown_timer.wait_time = cooldown
		is_active = false
		attack_timer.start(duration)

func attack_timeout():
	monitoring = false
	is_active = false
	debug.visible = false
	cooldown_timer.start()

func cooldown_timeout():
	is_active = true

func monitor_hits(hurt_box):
	if hurt_box is HurtBox and not ignore_hurt_box.has(hurt_box):
		debug.material_override.albedo_color = Color.RED
		hurt_box.melee_hit(damage)
