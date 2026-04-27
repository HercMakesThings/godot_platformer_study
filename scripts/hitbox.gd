class_name Hitbox extends Area2D

@export var default_hitbox_shape: CollisionShape2D
@export var kb_dir_visual: RayCast2D
@export var stats: HitboxStats = null
@export var default_stats: HitboxStats = null

var angle_vec: Vector2 = Vector2(1,0)

var is_active: bool
var orientation: int

var hitbox_shape: CollisionShape2D

signal hit_something(hitbox: Area2D, hurtbox: Area2D)

func _ready() -> void:
	hitbox_shape = default_hitbox_shape
	hitbox_shape.set_disabled(true)
	is_active = false
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hurtbox_contacted)
	orientation = 1
	add_to_group("atk_hitbox_group")
	if default_stats != null:
		stats = default_stats
	
func tick(_delta: float) -> void:
	## TODO: decide whether hitbox should handle its own orientation
	## or should the ability its tied to handle that
	position.x = abs(position.x)*orientation
	hitbox_shape.rotation_degrees = abs(hitbox_shape.rotation_degrees)*orientation
	flip_hitbox(orientation)
	## disable hitbox depending on is_active flag
	if is_active:
		hitbox_shape.set_disabled(false)
	else:
		hitbox_shape.set_disabled(true)
	
func flip_hitbox(dir: int) -> void:
	angle_vec = Vector2(abs(angle_vec.x)*dir, angle_vec.y)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func set_orientation(o: int) -> void:
	orientation = o
	
func init_stats(s: HitboxStats) -> void:
	stats = s
	if default_stats == null:
		default_stats = s
	hitbox_shape.rotation_degrees = s.rot * orientation
	var angle_radians: float = deg_to_rad(s.angle)
	angle_vec = angle_vec.rotated(angle_radians * orientation)
	var angle_dif = kb_dir_visual.target_position.angle_to(angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func _on_hit(body: Node2D):
	hit_something.emit(self, body)
	
func _on_hurtbox_contacted(_area: Area2D):
	pass
	#if area is Hurtbox:
