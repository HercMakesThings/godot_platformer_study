extends State
class_name PlayerJab3

@onready var animated_sprite = $"../../../AnimatedSprite2D"
@onready var player = $"../../.."
@onready var jab_3_hitbox = $Jab3Hitbox

signal is_player_attacking

var attack_frames: int

func Enter(_packet):
	attack_frames = 0
	is_player_attacking.emit()
	if player.player_dir > 0:
		animated_sprite.flip_h = false
	elif player.player_dir < 0:
		animated_sprite.flip_h = true
	animated_sprite.play("basic_attack_3")
	
func Update(_delta):
	#if attack_frames >= 16:
	if attack_frames >= jab_3_hitbox.move_length:
		state_transition.emit(self, "PlayerIdle")
		return
	attack_frames = attack_frames + 1
	
func Exit():
	pass
