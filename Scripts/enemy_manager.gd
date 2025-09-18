extends Node3D

@onready var state_machine = $StateMachine
@onready var enemy: CharacterBody3D = $CharacterBody3D
@onready var ticker: Timer = $Ticker
@onready var hit_box: HitBox = $CharacterBody3D/HitBox
@onready var hurt_box: HurtBox = $CharacterBody3D/HurtBox


var melee_range = 2.5
var ranged_range = 10
var player
var hp = 3
var current_hp = 3

var attack_delay = 0.0
var attack_threshold = 0.4

var has_ranged = false
var has_melee = true
var is_in_attack_range = false
var is_going_to_player = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player").character_body_3d
	hit_box.ignore_hurt_box.append(hurt_box) 
	state_machine.connect("attack",get_in_position)
	state_machine.connect("reposition",get_in_position)
	state_machine.connect("alert",stop_moving)
	hurt_box.connect("hit",Callable(self,"hit_register"))

func hit_register(dmg,type):
	current_hp -= dmg
	if current_hp <= 0:
		queue_free()



func go_to_player():
	if is_going_to_player == false and is_in_attack_range == false:
		enemy.target = player
		enemy.update_nav_target()
		is_going_to_player = true

func get_in_position():
	if ticker.is_stopped():
		ticker.start()

func stop_moving():
	is_going_to_player = false
	ticker.stop()
	enemy.target = enemy
	enemy.stop_nav()


func _on_ticker_timeout() -> void:
	if has_ranged:
		if enemy.global_position.distance_to(player.global_position) > ranged_range:
			is_in_attack_range = false
			go_to_player()
		else:
			is_in_attack_range = true
			stop_moving()
	elif has_melee:
		if enemy.global_position.distance_to(player.global_position) > melee_range:
			is_in_attack_range = false
			go_to_player()
		else:
			is_in_attack_range = true
			stop_moving()
	else:
		pass #run away
	if is_in_attack_range:
		attack_delay += ticker.wait_time
		if attack_delay >= attack_threshold:
			hit_box.attack_start()
	else:
		attack_delay = 0.0

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	state_machine.visible_on_screen()

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	state_machine.off_screen()

func _physics_process(delta: float) -> void:
	if is_going_to_player:
		enemy.look_at(player.global_position)
