extends State
class_name PlayerAirDodge

signal is_player_airdodging

var ad_frames: int
var ad_dir

@onready var player: Player = $"../.."

func Enter(_packet):
	ad_frames = 0
	ad_dir = Input.get_vector(
		"left_stick_left", 
		"left_stick_right", 
		"left_stick_up", 
		"left_stick_down").normalized()
	
func Update(_delta):
	
	#var ad_angle = Vector2.from_angle()
	
	#if ad_frames <= 24:
	is_player_airdodging.emit(ad_dir, ad_frames, _delta)
	
	
	#if ad_frames >= 30:
	#if ad_frames >= 16:
		#if player.is_on_floor():
			#state_transition.emit(self, "PlayerLandingLag")
		#else:
			#state_transition.emit(self, "PlayerMove")
	if player.is_on_floor():
		if ad_frames >= 16:
			state_transition.emit(self, "PlayerMove")
			return
	else:
		if ad_frames >= 30:
			state_transition.emit(self, "PlayerMove")
			return
	ad_frames += 1
	
func Exit():
	ad_frames = 0
