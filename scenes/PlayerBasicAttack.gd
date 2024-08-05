extends State
class_name PlayerBasicAttack

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var player = $"../.."

signal is_player_attacking

var attack_frames
var attack_count

#@onready var hitbox_1 = get_node("./atk_1_hitbox")
#@onready var atk_1_hitbox = $atk_1_hitbox

func Enter():
	attack_frames = 0
	attack_count = 1
	is_player_attacking.emit()
	var direction = Input.get_axis("run_left_test", "run_right_test")
	if player.dir == 1:
		animated_sprite_2d.flip_h = false
	elif player.dir == -1:
		animated_sprite_2d.flip_h = true
	elif player.dir == 0:
		if player.prev_dir == 1:
			animated_sprite_2d.flip_h = false
		elif player.prev_dir == -1:
			animated_sprite_2d.flip_h = true
	animated_sprite_2d.play("basic_attack_1")
	
	#add_child(atk_1_hitbox)
	
func Update(_delta):
	#atk_1_hitbox.shape_owner_get_shape()
	#self.remove_child(atk_1_hitbox)
	#if attack_frames == 15:
		#self.add_child(atk_1_hitbox)
	#if attack_count == 1:
		#animated_sprite_2d.play("basic_attack_1")
	if attack_frames >= 30:
		state_transition.emit(self, "PlayerIdle")
		return
	attack_frames = attack_frames + 1
	pass

func Exit():
	pass
