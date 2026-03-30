class_name HitboxNew extends Area2D

@export var body: CharacterBody2D
@export var default_hitbox_shape: CollisionShape2D
@export var kb_dir_visual: RayCast2D

#@export var active_window_begin: int = 12
#@export var active_window_end: int = 25
#@export var active_window: int = 13
#@export var move_length: int = 31

@export var dmg: float = 0.0
#@export_range(-180, 180, 1) var angle: float = 0.0
#@export_range(0, 360, 1) var angle: float = 0.0
#@export_range(0, 500, 1) var bkb: float = 0.0
#@export_range(0, 500, 1) var kbg: float = 0.0
var angle: float = 0.0
var bkb: float = 0.0
var kbg: float = 0.0
@export var lag: int = 4
@export var stun: int = 20

#@export var xoff: int = 0
#@export var yoff: int = 0
var xoff: float = 0
var yoff: float = 0
@export var rot: float = 0

var angle_vec := Vector2(1,0)

var kb_angle: Vector2 = Vector2(1,2).normalized()
var is_active: bool
var atk_frames: int
var count: int
var is_colliding: bool = false
var orientation: int

var hitbox_shape: CollisionShape2D

func _ready() -> void:
	hitbox_shape = default_hitbox_shape
	hitbox_shape.set_disabled(true)
	is_active = false
	is_colliding = false
	atk_frames = 0
	count = 0
	#top_level = true
	
	var angle_radians: float = deg_to_rad(angle)
	add_to_group("atk_hitbox_group")
	#kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_radians)
	angle_vec = angle_vec.rotated(angle_radians*orientation)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func tick(_delta: float) -> void:
	#print("player global position: " + str(body.global_position))
	#hitbox_shape.position = body.to_global(Vector2((xoff*body.movement_component.orientation), yoff))
	
	#hitbox_shape.position = body.to_global(Vector2((xoff*orientation), yoff))
	#global_position = body.global_position
	global_position = Vector2(body.global_position.x+(xoff*orientation), body.global_position.y+yoff)
	
	#hitbox_shape.global_position = body.global_position
	#print("hitbox global position: " + str(hitbox_shape.global_position))
	if is_active:
		hitbox_shape.set_disabled(false)
		atk_frames += 1
	else:
		hitbox_shape.set_disabled(true)
		if atk_frames > 0:
			atk_frames = 0
		
	#if orientation == 1:
		#set_rotation(-rot)
		##rotation_degrees = rot
	#elif orientation == -1:
		#set_rotation(rot)
		##rotation_degrees = -rot
	#set_rotation(rot*orientation)
	rotation_degrees = rot*orientation
		
	var angle_radians: float = deg_to_rad(angle)
	angle_vec = angle_vec.rotated(angle_radians * orientation)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
		
	flip_hitbox(orientation)
		
func flip_hitbox(dir: int) -> void:
	angle_vec = Vector2(abs(angle_vec.x)*dir, angle_vec.y)
	#if dir == -1:
		#if position.x > 0:
			#position.x *= -1
			##scale.x *= -1
			##angle -= 180
			##angle_vec.x *= -1
			#angle_vec = Vector2(-angle_vec.x, angle_vec.y)
	#elif dir == 1:
		#if position.x < 0:
			#position.x *= -1
			##scale.x *= -1
			##angle += 180
			##angle_vec.x *= -1
			#angle_vec = Vector2(-angle_vec.x, angle_vec.y)
	#var angle_vec = angle_vec.rotated(angle)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
