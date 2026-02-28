extends State
class_name PlayerMove

#@export var animated_sprite: AnimatedSprite2D
@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

var on_ground: bool

var p1_input

signal is_player_moving(dir, delta)
signal is_player_jumping(bool)
signal is_player_air_jumping(bool)
signal is_player_fast_falling(bool)

func get_player_axis(neg_action, pos_action):
	#return Input.get_vector("run_left_test", "run_right_test", "up_input_test", "up_input_test")
	return Input.get_action_strength(pos_action, true) - Input.get_action_strength(neg_action, true)

func Enter(_packet):
	#if player.dodge_buffer > 0.0 && player.air_dodge > 0:
			#state_transition.emit(self, "PlayerAirDodge")
	pass

func Update(_delta: float):
	p1_input = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up")
	# reset horizontal orientation
	#animated_sprite.flip_h = false
	
	# Handle jump.
	#if Input.is_action_pressed("jump_test") and player.is_on_floor():
	if Input.is_action_just_pressed("jump_test") and player.is_on_floor():
		state_transition.emit(self, "PlayerJumpSquat")
		return
		
	if Input.is_action_pressed("attack_1_test"):
		state_transition.emit(self, "PlayerBasicAttack")
		return
		
	var direction = Input.get_vector("run_left_test", "run_right_test", "down_input_test", "up_input_test")
	
	if player.is_on_floor():
		if direction.x == 0:
			state_transition.emit(self, "PlayerIdle")
			return
		#if Input.is_action_pressed("left_stick_down") && abs(p1_input.x) < 0.7:
		if Input.is_action_pressed("left_stick_down") && p1_input.y < -0.5:
			state_transition.emit(self, "PlayerCrouch")
			return
	else:
		on_ground = false
		#if player.dodge_buffer > 0.0 && player.air_dodge > 0:
			#state_transition.emit(self, "PlayerAirDodge")
		if Input.is_action_just_pressed("jump_test"):
			is_player_air_jumping.emit(true)
		elif Input.is_action_just_pressed("down_input_test") && player.velocity.y >= 0:
			is_player_fast_falling.emit(true)
		elif guard_pressed() && player.air_dodge > 0:
			state_transition.emit(self, "PlayerAirDodge")
			return
		
	if direction.x != 0:
		is_player_moving.emit(direction, _delta)
	
func guard_pressed():
	return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
	#return Input.is_action_pressed("guard_left") || Input.is_action_pressed("guard_right")
	
func Exit():
	pass
