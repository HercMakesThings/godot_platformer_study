extends State
class_name PlayerJab2

@onready var animated_sprite = $"../../../AnimatedSprite2D"
@onready var player = $"../../.."

signal is_player_attacking

var attack_frames

func Enter():
	attack_frames = 0
	is_player_attacking.emit()
	if player.player_dir > 0:
		animated_sprite.flip_h = false
	elif player.player_dir < 0:
		animated_sprite.flip_h = true
	animated_sprite.play("basic_attack_2")
	
func Update(delta: float):
	#if attack_frames > 4 && attack_frames < 10:
		#is_player_attacking.emit()
		#player.velocity.y -= 500 * delta
	if Input.is_action_just_pressed("attack_3_test"):
		state_transition.emit(self, "PlayerJab3")
		return
	if attack_frames >= 30:
		state_transition.emit(self, "PlayerIdle")
		return
	attack_frames = attack_frames + 1
	
func Exit():
	pass
	
