extends State
class_name PlayerMove

#@export var animated_sprite: AnimatedSprite2D
@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

var on_ground: bool

signal is_player_moving(dir, delta)
signal is_player_jumping(bool)
signal is_player_air_jumping(bool)
signal is_player_fast_falling(bool)

func get_player_axis(neg_action, pos_action):
	#return Input.get_vector("run_left_test", "run_right_test", "up_input_test", "up_input_test")
	return Input.get_action_strength(pos_action, true) - Input.get_action_strength(neg_action, true)

func Enter():
	pass

func Update(_delta: float):
	# reset horizontal orientation
	animated_sprite.flip_h = false
	
	# Handle jump.
	if Input.is_action_pressed("jump_test") and player.is_on_floor():
		#player.velocity.y = player.JUMP_VELOCITY
		#is_player_jumping.emit(true)
		state_transition.emit(self, "PlayerJumpSquat")
		return
		
	if Input.is_action_pressed("attack_1_test") && player.is_on_floor():
		state_transition.emit(self, "PlayerBasicAttack")
		return
		
	# Gets the input direction: -1, 0, or 1
	#var direction = Input.get_axis("run_left_test", "run_right_test")
	#var direction = get_player_axis("run_left_test", "run_right_test")
	var direction = Input.get_vector("run_left_test", "run_right_test", "down_input_test", "up_input_test")
	
	# play animations
	if player.is_on_floor():
		if direction.x == 0:
		#if direction == 0 and !Input.is_action_pressed("run_left_test") and !Input.is_action_pressed("run_right_test"):
			state_transition.emit(self, "PlayerIdle")
		else:
			if direction.x > 0:
				animated_sprite.play("walk_right")
			elif direction.x < 0:
				animated_sprite.play("walk_left")
	else:
		on_ground = false
		if Input.is_action_just_pressed("jump_test"):
			is_player_air_jumping.emit(true)
		elif Input.is_action_just_pressed("down_input_test") && player.velocity.y >= 0:
			is_player_fast_falling.emit()
		elif guard_pressed() && player.air_dodge > 0:
			state_transition.emit(self, "PlayerAirDodge")
		#if player.prev_dir_x_raw < 0:
			#animated_sprite.flip_h = true
		#elif player.prev_dir_x_raw > 0:
			#animated_sprite.flip_h = false
		if player.player_dir < 0:
			animated_sprite.flip_h = true
		elif player.player_dir > 0:
			animated_sprite.flip_h = false
		animated_sprite.play("in_air")
		
	if direction.x != 0:
		is_player_moving.emit(direction, _delta)
	
func guard_pressed():
	#return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
	return Input.is_action_pressed("guard_left") || Input.is_action_pressed("guard_right")
	
func Exit():
	pass
