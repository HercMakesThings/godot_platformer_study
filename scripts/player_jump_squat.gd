extends State
class_name PlayerJumpSquat

@onready var animated_sprite = $"../../AnimatedSprite2D"
#@onready var animated_sprite_js = $"../../AnimatedSprite2D2"
@onready var player = $"../.."

signal is_player_jumping(type: String)

var squat_frames

func Enter():
	squat_frames = 0


func Update(_delta):
	animated_sprite.play("jump_squat")
	#if squat_frames >= 3:
		#if Input.is_action_just_released("jump_test"):
			#is_player_jumping.emit("high")
			#state_transition.emit(self, "PlayerMove")
			#return
	#elif squat_frames < 3:
		#if Input.is_action_just_released("jump_test"):
			#is_player_jumping.emit("short")
			#state_transition.emit(self, "PlayerMove")
			#return
			
	#squat_frames += squat_frames
	squat_frames = squat_frames + 1
	#print(squat_frames)
	if Input.is_action_just_released("jump_test"):
		is_player_jumping.emit("short")
		state_transition.emit(self, "PlayerMove")
		return
	if squat_frames >= 4:
		is_player_jumping.emit("high")
		state_transition.emit(self, "PlayerMove")
		return
	
func Exit():
	pass
