extends State
class_name PlayerJab3

@onready var animated_sprite = $"../../../AnimatedSprite2D"
@onready var player = $"../../.."

signal is_player_attacking

var attack_frames: int

func Enter():
	attack_frames = 0
	is_player_attacking.emit()
	if player.player_dir > 0:
		animated_sprite.flip_h = false
	elif player.player_dir < 0:
		animated_sprite.flip_h = true
	animated_sprite.play("basic_attack_3")
	
func Update(_delta):
	if attack_frames >= 30:
		state_transition.emit(self, "PlayerIdle")
		return
	attack_frames = attack_frames + 1
	
func Exit():
	pass
