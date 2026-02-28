extends State
class_name PlayerDamaged

@onready var player = $"../.."
@onready var animated_sprite = $"../../AnimatedSprite2D"

signal is_in_hitlag
signal is_in_hitstun

var dmg_frames: int
var enemy_hitbox: Area2D

func Enter(area):
	dmg_frames = 0
	enemy_hitbox = area
	
func Update(_delta: float):
	#if dmg_frames < 4:
	if dmg_frames < enemy_hitbox.lag:
		animated_sprite.play("damaged")
		is_in_hitlag.emit(_delta)
	
	#if dmg_frames >= 5:
	if dmg_frames >= enemy_hitbox.lag:
		animated_sprite.play("damaged")
		is_in_hitstun.emit(_delta, enemy_hitbox)
		
	#if dmg_frames > 20:
	if dmg_frames > enemy_hitbox.stun:
		state_transition.emit(self, "PlayerIdle")
		return
	dmg_frames = dmg_frames + 1
	
func Exit():
	pass
