extends Node3D

@onready var character_body_3d: CharacterBody3D = $CharacterBody3D
@onready var player_camera: Camera3D = $Path3D/PathFollow3D/PlayerCamera
@onready var weapon_manager: Node = $WeaponManager
@onready var hurt_box: HurtBox = $CharacterBody3D/HurtBox

signal hit(dmg)

func _ready() -> void:
	player_camera.player = character_body_3d
	hurt_box.connect("hit",Callable(self,"hit_register"))

func hit_register(dmg,type):
	emit_signal("hit",dmg)

func input_reader(input):
	character_body_3d.movement_receiver(input)

func equip(weapon):
	weapon_manager.use_weapon(weapon)
