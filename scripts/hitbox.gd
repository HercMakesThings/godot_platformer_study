extends Area2D
class_name Hitbox

@onready var shape = $HitboxShape
@onready var kb_dir_visual = $RayCast2D

@export var dmg: float = 0.0
#@export_range(-180, 180, 1) var angle: float = 0.0
@export_range(0, 360, 1) var angle: float = 0.0
@export_range(0, 500, 1) var bkb: float = 0.0
@export_range(0, 500, 1) var kbg: float = 0.0
@export var lag: int = 4
@export var stun: int = 20

@export var xoff: int = 0
@export var yoff: int = 0
@export var rot: float = 0

var angle_vec := Vector2(1,0)

func _ready() -> void:
	var angle_radians: float = deg_to_rad(angle)
	self.add_to_group("atk_hitbox_group")
	#kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_radians)
	angle_vec = angle_vec.rotated(angle_radians)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func flip_hitbox(dir: int) -> void:
	if dir == 0:
		if position.x > 0:
			position.x *= -1
			#scale.x *= -1
			#angle -= 180
			#angle_vec.x *= -1
			angle_vec = Vector2(-angle_vec.x, angle_vec.y)
	elif dir == 1:
		if position.x < 0:
			position.x *= -1
			#scale.x *= -1
			#angle += 180
			#angle_vec.x *= -1
			angle_vec = Vector2(-angle_vec.x, angle_vec.y)
	#var angle_vec = angle_vec.rotated(angle)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
