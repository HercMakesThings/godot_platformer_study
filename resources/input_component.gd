class_name InputComponent extends Resource

@export var scheme: InputControlScheme

@export var buffer_size: int = 6

var input_buffer_arr: Array[InputPacket]

@export var deadzone_ls := .15
@export var deadzone_rs := .1
@export var hardpress_thresh_ls := .85

var packet: InputPacket

func init() -> void:
	packet = InputPacket.new()

func update() -> void:
	## reset packet
	packet.jump_pressed = false
	packet.jump_just_pressed = false
	packet.jump_just_released = false
	## end reset
	
	packet.primary_direction = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up", deadzone_ls)
	packet.secondary_direction = Input.get_vector("right_stick_left", "right_stick_right", "right_stick_down", "right_stick_up", deadzone_rs)
	
	for input in scheme.jump:
		packet.jump_pressed = Input.is_action_pressed(input) if !packet.jump_pressed else packet.jump_pressed
		packet.jump_just_pressed = Input.is_action_just_pressed(input) if !packet.jump_just_pressed else packet.jump_just_pressed
		packet.jump_just_released = Input.is_action_just_released(input) if !packet.jump_just_released else packet.jump_just_released
	#if scheme.jump.size() > 1:
		#if Input.is_action_pressed(scheme.jump[0]) || Input.is_action_pressed(scheme.jump[[1]]):
		
	for input in scheme.light_atk:
		packet.light_atk_pressed = Input.is_action_pressed(input)
		packet.light_atk_just_pressed = Input.is_action_just_pressed(input)
		packet.light_atk_released = Input.is_action_just_released(input)
		
	for input in scheme.heavy_atk:
		packet.heavy_atk_pressed = Input.is_action_pressed(input)
		packet.heavy_atk_just_pressed = Input.is_action_just_pressed(input)
		packet.heavy_atk_released = Input.is_action_just_released(input)
		
	for input in scheme.special_atk:
		packet.special_atk_pressed = Input.is_action_pressed(input)
		packet.special_atk_just_pressed = Input.is_action_just_pressed(input)
		packet.special_atk_released = Input.is_action_just_released(input)
		
	for input in scheme.guard:
		packet.is_guard_pressed = Input.is_action_pressed(input)
		packet.is_guard_just_pressed = Input.is_action_just_pressed(input)
		packet.is_guard_released = Input.is_action_just_released(input)
		
	#for input in scheme.start
	
	input_buffer_arr.push_front(packet)
	if input_buffer_arr.size() > buffer_size:
		input_buffer_arr.pop_back()
	
func get_current_packet() -> InputPacket:
	return input_buffer_arr[0]
	
func get_buffer(size: int = 0) -> Array[InputPacket]:
	if size == 0:
		return input_buffer_arr
	return input_buffer_arr.slice(0, size)
