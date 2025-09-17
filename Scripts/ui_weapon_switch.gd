extends Control
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_melee_pressed() -> void:
	player.equip("melee")

func _on_hit_scan_pressed() -> void:
	player.equip("hit_scan")

func _on_projectile_pressed() -> void:
	player.equip("projectile")

func _input(event: InputEvent) -> void:
	if event.is_action("slot_1"):
		_on_melee_pressed()
	elif event.is_action("slot_2"):
		_on_hit_scan_pressed()
	elif event.is_action("slot_3"):
		_on_projectile_pressed()
