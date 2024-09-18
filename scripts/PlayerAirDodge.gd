extends State
class_name PlayerAirDodge

signal is_player_airdodging

var ad_frames: int
var ad_dir

func Enter():
	ad_dir = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_up", "left_stick_down").normalized()
	
func Update(_delta):
	
	#var ad_angle = Vector2.from_angle()
	
	#if ad_frames <= 24:
	is_player_airdodging.emit(ad_dir, ad_frames, _delta)
	
	
	if ad_frames >= 31:
		state_transition.emit(self, "PlayerIdle")
	ad_frames += 1
	
func Exit():
	ad_frames = 0
