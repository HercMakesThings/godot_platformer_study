extends State
class_name PlayerIdle

#@export var animated_sprite: AnimatedSprite2D
@onready var animated_sprite = $"../../AnimatedSprite2D"
@onready var player = $"../.."


func Enter():
	animated_sprite.flip_h = false
	if player.dir == 1:
		animated_sprite.flip_h = false
	elif player.dir == -1:
		animated_sprite.flip_h = true
	elif player.dir == 0:
		if player.prev_dir == 1:
			animated_sprite.flip_h = false
		elif player.prev_dir == -1:
			animated_sprite.flip_h = true
	animated_sprite.play("idle")
	pass

func Update(_delta: float):
	if abs(player.velocity.x) > 0:
		#player.velocity.x = 0
		player.velocity.x = move_toward(player.velocity.x, 0, _delta * 600)
	if not player.is_on_floor():
		state_transition.emit(self, "PlayerMove")
	if Input.is_action_just_pressed("run_right_test") or Input.is_action_just_pressed("run_left_test"):
		state_transition.emit(self, "PlayerMove")
	if Input.is_action_pressed("jump_test") and player.is_on_floor():
		state_transition.emit(self, "PlayerJumpSquat")
	if Input.is_action_pressed("attack_1_test"):
		state_transition.emit(self, "PlayerBasicAttack")

func Exit():
	pass
