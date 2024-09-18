extends State
class_name PlayerBasicAttack

#@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var animated_sprite_2d = $"../../../AnimatedSprite2D"

#@onready var player = $"../.."
@onready var player = $"../../.."

signal is_player_attacking
signal is_player_fast_falling

var attack_frames
var attack_count

#@onready var hitbox = $"../../Hitbox"
@onready var hitbox = $"../../../Hitbox"

#@onready var hitbox_1 = get_node("./atk_1_hitbox")
#@onready var atk_1_hitbox = $atk_1_hitbox

func Enter():
	attack_frames = 0
	attack_count = 1
	is_player_attacking.emit()
	#var direction = Input.get_axis("run_left_test", "run_right_test")
	if player.x_dir_raw > 0:
		animated_sprite_2d.flip_h = false
	elif player.x_dir_raw < 0:
		animated_sprite_2d.flip_h = true
	elif player.x_dir_raw == 0:
		if player.prev_dir > 0:
			animated_sprite_2d.flip_h = false
		elif player.prev_dir < 0:
			animated_sprite_2d.flip_h = true
	animated_sprite_2d.play("basic_attack_1")
	
func Update(_delta):
	if Input.is_action_just_pressed("down_input_test") && player.velocity.y >= 0:
			is_player_fast_falling.emit()
	if Input.is_action_just_pressed("attack_2_test"):
		state_transition.emit(self, "PlayerJab2")
	if attack_frames >= 30:
		state_transition.emit(self, "PlayerIdle")
		return
	attack_frames = attack_frames + 1
	
func Exit():
	pass
