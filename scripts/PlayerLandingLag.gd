extends State
class_name PlayerLandingLag

@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

var landing_frames

signal is_in_landing_lag

func Enter():
	landing_frames = 0
	
func Update(delta):
	landing_frames += 1
	if landing_frames <= 4:
		is_in_landing_lag.emit()
		animated_sprite.play("landing_lag")
	else:
		state_transition.emit(self, "PlayerIdle")
	
func Exit():
	pass
