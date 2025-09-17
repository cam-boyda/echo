extends Node
class_name StateMachine

enum STATE {
	IDLE,
	ALERT,
	REPOSITION,
	ATTACK
}

@onready var enemy: Node3D = $".."
var current_state : STATE = STATE.IDLE
var visible_notifier = VisibleOnScreenNotifier3D.new()
var reaction_timer = Timer.new()

func _ready() -> void:
	add_child(reaction_timer)
	reaction_timer.one_shot = true
	enemy.add_child.call_deferred(visible_notifier)
	visible_notifier.connect("screen_entered",visible_on_screen)

func change_state(new_state : STATE):
	reaction_timer.start()
	reaction_timer.wait_time = randf_range(0.2,0.5)
	await reaction_timer.timeout
	match new_state:
		STATE.IDLE:
			print("idle")
		STATE.ALERT:
			print("alert")
		STATE.REPOSITION:
			print("repositioning")
		STATE.ATTACK:
			print("attacking")

func visible_on_screen():
	change_state(STATE.ALERT)
