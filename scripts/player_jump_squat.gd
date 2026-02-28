extends State
class_name PlayerJumpSquat

@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

signal is_player_jumping(type: String)

var squat_frames

func Enter(_packet):
	squat_frames = 0


func Update(_delta):
	animated_sprite.play("jump_squat")
	squat_frames = squat_frames + 1
	#print(squat_frames)
	if Input.is_action_just_released("jump_test"):
		is_player_jumping.emit("short", _delta)
		state_transition.emit(self, "PlayerMove")
		return
	if guard_pressed() && squat_frames <= 4:
		is_player_jumping.emit("short", _delta)
		state_transition.emit(self, "PlayerAirDodge")
		return
	if squat_frames >= 4:
		is_player_jumping.emit("high", _delta)
		state_transition.emit(self, "PlayerMove")
		return
	
func Exit():
	pass
	
func guard_pressed():
	return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
