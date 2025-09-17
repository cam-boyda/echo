extends Camera3D

var player
var scroll_speed = 5
var rotate_speed = 10

@onready var path_follow_3d: PathFollow3D = $".."
@onready var path_3d: Path3D = $"../.."

var mouse_movement = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		if abs(mouse_movement.x) <= 3:
			mouse_movement.x = 0
		if abs(mouse_movement.y) <= 3:
			mouse_movement.y = 0

func _physics_process(delta: float) -> void:
	look_at(player.position)
	if Input.is_action_pressed("camera_adjust"):
		if Input.is_action_just_pressed("zoom_in"):
			path_follow_3d.progress_ratio = move_toward(path_follow_3d.progress_ratio,1,delta*scroll_speed)
		elif Input.is_action_just_pressed("zoom_out"):
			path_follow_3d.progress_ratio = move_toward(path_follow_3d.progress_ratio,0,delta*scroll_speed)
		path_3d.rotate_y(deg_to_rad(delta*mouse_movement.x*rotate_speed))
