class_name InputPacket extends Resource

var start_pressed: bool
var start_just_pressed: bool
var start_released: bool

var primary_direction: Vector2
var secondary_direction: Vector2

var is_secondary_direction_locked: bool = false

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
	var is_atk_pressed: bool = primary_direction.y < -deadzone && (light_atk_just_pressed || light_atk_pressed)
	if scheme.second_stick_type == "light" && !is_secondary_direction_locked:
		if secondary_direction.y < -deadzone:
			#lock_secondary_direction()
			call_deferred("lock_secondary_direction")
		return secondary_direction.y < -deadzone || is_atk_pressed
	return is_atk_pressed
	
func is_up_light_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	var is_atk_pressed: bool = primary_direction.y > deadzone && (light_atk_just_pressed || light_atk_pressed)
	if scheme.second_stick_type == "light" && !is_secondary_direction_locked:
		if secondary_direction.y > deadzone:
			#lock_secondary_direction()
			call_deferred("lock_secondary_direction")
		return secondary_direction.y > deadzone || is_atk_pressed
	return is_atk_pressed
	
func is_neutral_light_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	var is_atk_pressed: bool = absf(primary_direction.y) < deadzone && (light_atk_just_pressed || light_atk_pressed)
	if scheme.second_stick_type == "light" && !is_secondary_direction_locked:
		if absf(secondary_direction.y) < deadzone:
			#lock_secondary_direction()
			call_deferred("lock_secondary_direction")
		return absf(secondary_direction.y) < deadzone || is_atk_pressed
	return is_atk_pressed
	
func is_any_atk_just_pressed(scheme: InputControlScheme, deadzone: float) -> bool:
	#var is_atk_pressed: bool = light_atk_just_pressed || light_atk_pressed
	var is_atk_pressed: bool = light_atk_just_pressed
	if scheme.second_stick_type == "light" && !is_secondary_direction_locked:
		if absf(secondary_direction.x) > deadzone || absf(secondary_direction.y) > deadzone:
			#lock_secondary_direction()
			call_deferred("lock_secondary_direction")
		return is_atk_pressed || (absf(secondary_direction.x) > deadzone || absf(secondary_direction.y) > deadzone)
	return is_atk_pressed
	
func lock_secondary_direction() -> void:
	if !is_secondary_direction_locked:
		is_secondary_direction_locked = true
		
func unlock_secondary_direction(deadzone: float) -> void:
	if absf(secondary_direction.x) < deadzone && absf(secondary_direction.y) < deadzone:
		is_secondary_direction_locked = false
			
