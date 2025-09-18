extends Area3D
class_name HurtBox

signal hit(dmg,type)

func hit_scan_hit(dmg):
	emit_signal("hit",dmg,"hit_scan")

func melee_hit(dmg):
	emit_signal("hit",dmg,"hit_box")

func projectile_hit(dmg):
	emit_signal("hit",dmg,"projectile")
