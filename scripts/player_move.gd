extends State
class_name PlayerMove

#@export var animated_sprite: AnimatedSprite2D
@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."

signal is_player_moving(dir, delta)
signal is_player_jumping(bool)

func get_player_axis(neg_action, pos_action):
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
		
	if Input.is_action_pressed("attack_1_test"):
		state_transition.emit(self, "PlayerBasicAttack")
		return
		
	# Gets the input direction: -1, 0, or 1
	#var direction = Input.get_axis("run_left_test", "run_right_test")
	var direction = get_player_axis("run_left_test", "run_right_test")
		
	# play animations
	if player.is_on_floor():
		if direction == 0 and !Input.is_action_pressed("run_left_test") and !Input.is_action_pressed("run_right_test"):
			state_transition.emit(self, "PlayerIdle")
		else:
			if direction > 0:
				animated_sprite.play("walk_right")
			elif direction < 0:
				animated_sprite.play("walk_left")
	else:
		#if player.dir == 1:
			#animated_sprite.flip_h = false
		#elif player.dir == -1:
			#animated_sprite.flip_h = true
		#elif player.dir == 0:
			#if player.prev_dir == 1:
				#animated_sprite.flip_h = false
			#elif player.prev_dir == -1:
				#animated_sprite.flip_h = true
		if player.prev_dir == -1:
			animated_sprite.flip_h = true
		elif player.prev_dir == 1:
			animated_sprite.flip_h = false
		animated_sprite.play("in_air")
		
	if direction != 0:
		is_player_moving.emit(direction, _delta)
	#else:
		##player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
		#is_player_moving.emit(direction, _delta)

func Exit():
	pass
