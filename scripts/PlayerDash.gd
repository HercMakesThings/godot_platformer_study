extends State
class_name PlayerDash

@onready var player = $"../.."
@onready var animated_sprite = $"../../AnimatedSprite2D"

signal is_player_dashing

var dash_frames: int
var pl_input: Vector2

func Enter(_packet):
	dash_frames = 0
	#is_player_dashing.emit()
	pass
	
func Update(_delta: float):
	pl_input = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up")
	dash_frames += 1
	is_player_dashing.emit(pl_input, _delta)
	
	if dash_frames >= 16:
		state_transition.emit(self, "PlayerMove")
		return
		
	if player.is_on_floor():
		if Input.is_action_just_pressed("jump_test") and player.is_on_floor():
			state_transition.emit(self, "PlayerJumpSquat")
			return
			
		if Input.is_action_pressed("attack_1_test"):
			state_transition.emit(self, "PlayerBasicAttack")
			return
	else:
		state_transition.emit(self, "PlayerMove")
		return
	
func Exit():
	dash_frames = 0
	pass
