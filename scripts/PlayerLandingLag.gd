extends State
class_name PlayerLandingLag

@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

var landing_frames

signal is_in_landing_lag

func Enter(_packet):
	landing_frames = 0
	
func Update(delta):
	landing_frames += 1
	if landing_frames <= 4:
		is_in_landing_lag.emit()
		animated_sprite.play("landing_lag")
		if landing_frames > 2:
			if Input.is_action_pressed("jump_test"):
				state_transition.emit(self, "PlayerJumpSquat")
				return
	else:
		var pl_input = Input.get_vector("run_left_test", "run_right_test", "down_input_test", "up_input_test")
		if pl_input.x != 0:
			state_transition.emit(self, "PlayerMove")
			return
		else:
			state_transition.emit(self, "PlayerIdle")
			return
		if Input.is_action_pressed("jump_test"):
			state_transition.emit(self, "PlayerJumpSquat")
			return
	
func Exit():
	landing_frames = 0
	pass
