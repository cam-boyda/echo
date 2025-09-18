extends Node
class_name StateMachine

enum STATE {
	IDLE,
	ALERT,
	REPOSITION,
	ATTACK
}

@onready var enemy: Node3D = $".."

var player_last_seen

var current_state : STATE = STATE.IDLE
var is_looking_for_player
var player

var lose_interest_timer = 0.0
var lose_interest_threshold = 5.0

signal idle
signal alert
signal reposition
signal attack

func change_state(new_state : STATE):
	match new_state:
		STATE.IDLE:
			emit_signal("idle")
			is_looking_for_player = false
		STATE.ALERT:
			emit_signal("alert")
			if get_tree().get_first_node_in_group("player"):
				player = enemy.player
				is_looking_for_player = true
		STATE.REPOSITION:
			emit_signal("reposition")
		STATE.ATTACK:
			emit_signal("attack")
	current_state = new_state

func visible_on_screen():
	if current_state == STATE.IDLE:
		change_state(STATE.ALERT)

func off_screen():
	if current_state == STATE.ALERT:
		change_state(STATE.IDLE)

func CheckLOS(pos):
	var enemy_pos = enemy.enemy.global_position
	var player_pos = pos
	var space = enemy.enemy.get_world_3d().direct_space_state
	var rayquery = PhysicsRayQueryParameters3D.create(enemy_pos,player_pos)
	var result = space.intersect_ray(rayquery)
	if result.keys().is_empty() == false:
		if result["collider"] == player:
			player_last_seen = result["position"]
			return true
		else:
			return false
	else:
		return false

func _process(delta: float) -> void:
	if is_looking_for_player:
		var player_pos = player.global_position
		if CheckLOS(player_pos):
			change_state(STATE.ATTACK)
			lose_interest_timer = 0.0
		else:
			if current_state != STATE.ALERT:
				change_state(STATE.REPOSITION)
				lose_interest_timer += delta
				if lose_interest_timer >= lose_interest_threshold:
					change_state(STATE.ALERT)
