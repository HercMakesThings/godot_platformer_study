class_name PlayerCrouch
extends State

@onready var player = $"../.."
@onready var animated_sprite = $"../../AnimatedSprite2D"

var crouch_frames: int
var p1_input

signal is_player_crouching

func Enter(_packet):
	#if p1_input == null:
		#p1_input = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up")
	crouch_frames = 0
	animated_sprite.flip_h = false
	#if player.x_dir_raw == 1:
	if player.x_dir_raw > 0:
		animated_sprite.flip_h = false
	#elif player.x_dir_raw == -1:
	elif player.x_dir_raw < 0:
		animated_sprite.flip_h = true
	elif player.x_dir_raw == 0:
		#if player.prev_dir_x_raw == 1:
		if player.prev_dir_x_raw > 0:
			animated_sprite.flip_h = false
		#elif player.prev_dir_x_raw == -1:
		elif player.prev_dir_x_raw < 0:
			animated_sprite.flip_h = true
	animated_sprite.play("crouch")
	
func Update(_delta: float):
	p1_input = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up")
	if Input.is_action_pressed("left_stick_down"):
		is_player_crouching.emit()
	else:
		state_transition.emit(self, "PlayerIdle")
		return
	if Input.is_action_just_pressed("jump_test"):
		state_transition.emit(self, "PlayerJumpSquat")
		return
	if abs(p1_input.x) > 0.7:
		state_transition.emit(self, "PlayerMove")
		return
		#state_transition.emit(self, "PlayerIdle")
	crouch_frames += 1
	
func Exit():
	crouch_frames = 0
	#p1_input = null
