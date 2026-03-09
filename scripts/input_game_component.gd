class_name InputGameComponent extends Node

var dir_input := Vector2.ZERO
var rs_input := Vector2.ZERO

var btn_0_input: bool = false
var btn_1_input: bool = false
var btn_2_input: bool = false
var btn_3_input: bool = false
var guard_input: bool = false

var btn_0_input_released: bool = false
var btn_1_input_released: bool = false
var btn_2_input_released: bool = false
var btn_3_input_released: bool = false
var guard_input_released: bool = false


@export var deadzone_ls := .15
@export var deadzone_rs := .1
@export var hardpress_thresh_ls := .85


func update() -> void:
	dir_input = Input.get_vector("left_stick_left", "left_stick_right", "left_stick_down", "left_stick_up", deadzone_ls)
	rs_input = Input.get_vector("right_stick_left", "right_stick_right", "right_stick_down", "right_stick_up", deadzone_rs)
	#btn_0_input = Input.is_action_just_pressed("btn_0")
	btn_0_input = Input.is_action_pressed("btn_0")
	btn_0_input_released = Input.is_action_just_released("btn_0")
	#btn_1_input = Input.is_action_just_pressed("btn_1")
	btn_1_input = Input.is_action_pressed("btn_1")
	btn_1_input_released = Input.is_action_just_released("btn_1")
	#btn_2_input = Input.is_action_just_pressed("btn_2")
	btn_2_input = Input.is_action_pressed("btn_2")
	btn_2_input_released = Input.is_action_just_released("btn_2")
	#btn_3_input = Input.is_action_just_pressed("jump_test")
	btn_3_input = Input.is_action_just_pressed("btn_3")
	#btn_3_input = Input.is_action_pressed("btn_3")
	btn_3_input_released = Input.is_action_just_released("btn_3")
	
	guard_input = is_guard_pressed()
	
	#debug
	#if Input.is_action_just_pressed("btn_3"):
		#print("jump pressed!")
	
func is_guard_pressed() -> bool:
	return Input.is_action_pressed("guard_left") || Input.is_action_pressed("guard_right")
	#return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
