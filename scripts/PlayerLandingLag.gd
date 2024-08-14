extends State
class_name PlayerLandingLag

@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

var landing_frames

signal is_in_landing_lag

func Enter():
	landing_frames = 0
	
func Update(delta):
	if landing_frames <= 5:
		is_in_landing_lag.emit()
		animated_sprite.play("landing_lag")
	else:
		state_transition.emit(self, "PlayerIdle")
	landing_frames = landing_frames + 1
	
func Exit():
	pass
