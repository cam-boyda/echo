extends RayCast3D
class_name HitScan

var is_active = true
var cooldown_timer : Timer = Timer.new()
var attack_timer : Timer = Timer.new()

func _ready() -> void:
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout",cooldown_timeout)
	cooldown_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout",attack_timeout)
	attack_timer.one_shot = true
	enabled = false

func attack_start(duration : float = 0.1, cooldown : float = 0.2):
	if is_active:
		enabled = true
		cooldown_timer.wait_time = cooldown
		is_active = false
		attack_timer.start(duration)

func cooldown_timeout():
	is_active = true

func attack_timeout():
	if get_collider():
			if get_collider() is HurtBox:
				get_collider().hit_scan_hit()
	is_active = false
	enabled = false
	cooldown_timer.start()
