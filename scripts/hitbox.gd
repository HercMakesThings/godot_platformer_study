class_name Hitbox extends Area2D

@export var default_hitbox_shape: CollisionShape2D
@export var kb_dir_visual: RayCast2D
@export var stats: HitboxStats = null
@export var default_stats: HitboxStats = null

@export var stats_array: Array[HitboxStats]
@export var shapes_array: Array[CollisionShape2D]
@export var angle_visual_array: Array[RayCast2D]

var is_active: bool
var orientation: int
#var hit_hurtbox_rid: RID

var hitbox_shape: CollisionShape2D

var collided_hurtboxes: Array[Hurtbox]

#signal hit_something(hitbox: Area2D, hurtbox: Area2D)
signal shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D)

func _ready() -> void:
	#hitbox_shape = default_hitbox_shape
	#if hitbox_shape != null:
		#hitbox_shape.set_disabled(true)
	is_active = false
	#hit_hurtbox_rid = RID()
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hurtbox_contacted)
	body_shape_entered.connect(_on_area_2d_body_shape_entered)
	orientation = 1
	add_to_group("atk_hitbox_group")
	if default_stats != null:
		stats = default_stats
	if get_child_count() > 0 && shapes_array.size() == 0:
		for child in get_children():
			if child is CollisionShape2D:
				shapes_array.append(child)
			elif child is RayCast2D:
				angle_visual_array.append(child)
		
	
func tick(_delta: float) -> void:
	## TODO: decide whether hitbox should handle its own orientation
	## or should the ability its tied to handle that
	#position.x = abs(position.x)*orientation
	#hitbox_shape.rotation_degrees = abs(hitbox_shape.rotation_degrees)*orientation
	#flip_hitbox(orientation)
	### disable hitbox depending on is_active flag
	#if is_active:
		#hitbox_shape.set_disabled(false)
	#else:
		#hitbox_shape.set_disabled(true)
	for i in range(stats_array.size()):
		shapes_array[i].set_disabled(!stats_array[i].is_active)
		shapes_array[i].position.x = abs(shapes_array[i].position.x)*orientation
		angle_visual_array[i].position.x = abs(angle_visual_array[i].position.x)*orientation
		shapes_array[i].rotation_degrees = abs(shapes_array[i].rotation_degrees)*orientation
		stats_array[i].angle_vec = Vector2(abs(stats_array[i].angle_vec.x)*orientation, stats_array[i].angle_vec.y)
		var angle_dif = angle_visual_array[i].target_position.angle_to(stats_array[i].angle_vec)
		angle_visual_array[i].target_position = angle_visual_array[i].target_position.rotated(angle_dif)
	
func flip_hitbox(dir: int) -> void:
	stats.angle_vec = Vector2(abs(stats.angle_vec.x)*dir, stats.angle_vec.y)
	var angle_dif = kb_dir_visual.target_position.angle_to(stats.angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func set_orientation(o: int) -> void:
	orientation = o
	
func init_stats(s: HitboxStats) -> void:
	stats = s
	if default_stats == null:
		default_stats = s
	hitbox_shape.rotation_degrees = s.rot * orientation
	var angle_radians: float = deg_to_rad(s.angle)
	stats.angle_vec = stats.angle_vec.rotated(angle_radians * orientation)
	var angle_dif: float = kb_dir_visual.target_position.angle_to(stats.angle_vec)
	kb_dir_visual.target_position = kb_dir_visual.target_position.rotated(angle_dif)
	
func init_shape_stats(list: Array[HitboxStats]):
	var count: int = 0
	for statblock in list:
		shapes_array[count].rotation_degrees = statblock.rot * orientation
		var angle_radians: float = deg_to_rad(statblock.angle)
		statblock.angle_vec = statblock.angle_vec.rotated(angle_radians * orientation)
		var angle_dif: float = angle_visual_array[count].target_position.angle_to(statblock.angle_vec)
		angle_visual_array[count].target_position = angle_visual_array[count].target_position.rotated(angle_dif)
		count += 1
	if stats_array.size() == 0:
		stats_array = list
	
func _on_hit(_body: Node2D):
	#hit_something.emit(self, body)
	pass
	
func _on_hurtbox_contacted(_area: Area2D):
	pass
	#if area is Hurtbox:
	
func _on_area_2d_body_shape_entered(_body_rid, body, _body_shape_index, local_shape_index) -> void:
	# Add to list of hurtboxes hitbox has contacted (while move is active)
	if body is Hurtbox && body not in collided_hurtboxes:
		collided_hurtboxes.append(body)
		# Find the shape owner ID using the index
		var shape_owner_id: int = shape_find_owner(local_shape_index)
		# Get the actual CollisionShape2D node from that owner
		#var shape_node: CollisionShape2D = shape_owner_get_owner(shape_owner_id)
		shape_hit_something.emit(self, shape_owner_id, body)
	
