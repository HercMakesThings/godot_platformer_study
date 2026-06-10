class_name InputPacket extends Resource

var start_pressed: bool
var start_just_pressed: bool
var start_released: bool

var primary_direction: Vector2
var secondary_direction: Vector2

var jump_pressed: bool
var jump_just_pressed: bool
var jump_just_released: bool

var light_atk_pressed: bool
var light_atk_just_pressed: bool
var light_atk_released: bool

var heavy_atk_pressed: bool
var heavy_atk_just_pressed: bool
var heavy_atk_released: bool

var special_atk_pressed: bool
var special_atk_just_pressed: bool
var special_atk_released: bool

var is_guard_pressed: bool
var is_guard_just_pressed: bool
var is_guard_released: bool

func is_down_light_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	if scheme.second_stick_type == "light":
		return secondary_direction.y < -deadzone
	return primary_direction.y < -deadzone && (light_atk_just_pressed || light_atk_pressed)
	
func is_uplight_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	if scheme.second_stick_type == "light":
		return secondary_direction.y > deadzone
	return primary_direction.y > deadzone && (light_atk_just_pressed || light_atk_pressed)
	
func is_neutral_light_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	if scheme.second_stick_type == "light":
		return absf(secondary_direction.y) < deadzone
	return absf(primary_direction.y) < deadzone && (light_atk_just_pressed || light_atk_pressed)
			
