class_name Hitbox extends Area2D

@export var stats_array: Array[HitboxStats]
@export var shapes_array: Array[CollisionShape2D]
@export var angle_visual_array: Array[RayCast2D]

var is_active: bool
var orientation: int

var hitbox_shape: CollisionShape2D

var collided_hurtboxes: Array[Hurtbox]
var owner_hurtbox: Hurtbox

signal shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D)

func _ready() -> void:
	monitorable = false
	is_active = false
	area_shape_entered.connect(_on_area_2d_body_shape_entered)
	orientation = 1
	add_to_group("atk_hitbox_group")
	if get_child_count() > 0 && shapes_array.size() == 0:
		for child in get_children():
			if child is CollisionShape2D:
				shapes_array.append(child)
			elif child is RayCast2D:
				angle_visual_array.append(child)
	init_shape_stats()
		
	
func tick(_delta: float) -> void:
	## TODO: decide whether hitbox should handle its own orientation
	## or should the ability its tied to handle that
	
	for i in range(stats_array.size()):
		shapes_array[i].set_disabled(!stats_array[i].is_active)
		shapes_array[i].visible = stats_array[i].is_active
		angle_visual_array[i].visible = stats_array[i].is_active
		shapes_array[i].position.x = abs(shapes_array[i].position.x)*orientation
		angle_visual_array[i].position.x = abs(angle_visual_array[i].position.x)*orientation
		shapes_array[i].rotation_degrees = abs(shapes_array[i].rotation_degrees)*orientation
		stats_array[i].angle_vec = Vector2(abs(stats_array[i].angle_vec.x)*orientation, stats_array[i].angle_vec.y)
		var angle_dif = angle_visual_array[i].target_position.angle_to(stats_array[i].angle_vec)
		angle_visual_array[i].target_position = angle_visual_array[i].target_position.rotated(angle_dif)
	
func set_orientation(o: int) -> void:
	orientation = o
	
func init_shape_stats():
	if !stats_array:
		return
	var count: int = 0
	for statblock in stats_array:
		shapes_array[count].rotation_degrees = statblock.rot * orientation
		var angle_radians: float = deg_to_rad(statblock.angle)
		statblock.angle_vec = statblock.angle_vec.rotated(angle_radians * orientation)
		var angle_dif: float = angle_visual_array[count].target_position.angle_to(statblock.angle_vec)
		angle_visual_array[count].target_position = angle_visual_array[count].target_position.rotated(angle_dif)
		shapes_array[count].visible = statblock.is_active
		angle_visual_array[count].visible = statblock.is_active
		count += 1
	
func _on_area_2d_body_shape_entered(area_rid: RID, area: Node2D, _area_shape_index: int, local_shape_index: int) -> void:
	# Add to list of hurtboxes hitbox has contacted (while move is active)
	if owner_hurtbox == null:
		return
	if area is not Hurtbox:
		return
	if area in collided_hurtboxes:
		return
	if owner_hurtbox.get_rid() == area_rid:
		return
	collided_hurtboxes.append(area)
	## Find the shape owner ID using the index
	var shape_owner_id: int = shape_find_owner(local_shape_index)
	## Get the actual CollisionShape2D node from that owner
	##var shape_node: CollisionShape2D = shape_owner_get_owner(shape_owner_id)
	shape_hit_something.emit(self, shape_owner_id, area)
	area.contacted(self, get_rid(), local_shape_index)
