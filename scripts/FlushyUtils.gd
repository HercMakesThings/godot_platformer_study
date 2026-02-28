extends Node
class_name FlushyUtils

## function for calculating a character's knockback when they are hit
static func calc_kb(area: Area2D, percent: float, weight: float)->float:
	var angle = deg_to_rad(area.angle)
	#var force = Vector2(1,0).rotated(angle).normalized()
	#var force = area.angle_vec.normalized()
	var dmg = area.dmg
	var bkb = area.bkb
	var kbg = area.kbg / 100.0
	#var kbg = area.kbg
	var p = percent
	#var kb = ((p + (dmg*p) + bkb)*kbg) / (weight * 1)
	#var kb = ((((p + (dmg*p))*(50/(weight+10)))*kbg)+bkb)
	return ((((p + (dmg*p))*(50/(weight+10)))*kbg)+bkb)
	#force = force * kb
	#return force
	
static func calc_hitstun(kb: float, mod := 0) -> int:
	return int(kb * 0.4) + mod
