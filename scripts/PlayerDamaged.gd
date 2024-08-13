extends State
class_name PlayerDamaged

@onready var player = $"../.."
@onready var animated_sprite = $"../../AnimatedSprite2D"

signal is_in_hitlag
signal is_in_hitstun

var dmg_frames: int

func Enter():
	dmg_frames = 0
	
func Update(_delta: float):
	if dmg_frames < 4:
		animated_sprite.play("damaged")
		is_in_hitlag.emit(_delta)
	
	if dmg_frames >= 5:
		animated_sprite.play("damaged")
		is_in_hitstun.emit(_delta)
		
	if dmg_frames > 25:
		state_transition.emit(self, "PlayerIdle")
	dmg_frames = dmg_frames + 1
	
func Exit():
	pass
