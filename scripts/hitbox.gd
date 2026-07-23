class_name Hitbox extends Area2D

@export var shapes_array: Array[CollisionShape2D]

var is_active: bool
#var orientation: int

var hitbox_shape: CollisionShape2D

var collided_hurtboxes: Array[Hurtbox]
var owner_hurtbox: Hurtbox

signal shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D)

var _debug: bool
var shape_angle_vis_arr: PackedVector2Array

func _ready() -> void:
	monitorable = false
	monitoring = true
	is_active = false
	area_shape_entered.connect(_on_area_2d_body_shape_entered)
	#orientation = 1
	add_to_group("atk_hitbox_group")
	if get_child_count() > 0 && shapes_array.size() == 0:
		for child in get_children():
			if child is CollisionShape2D:
				shapes_array.append(child)
	
func _physics_process(_delta: float) -> void:
	if _debug:
		queue_redraw()
	
#func set_orientation(o: int) -> void:
	#orientation = o
	
func set_debug(d: bool) -> void:
	_debug = d
	
func _on_area_2d_body_shape_entered(area_rid: RID, area: Node2D, _area_shape_index: int, local_shape_index: int) -> void:
	if owner_hurtbox == null:
		return
	if area is not Hurtbox:
		return
	if area in collided_hurtboxes:
		return
	if owner_hurtbox.get_rid() == area_rid:
		return
	## Add to list of hurtboxes hitbox has contacted (while move is active)
	collided_hurtboxes.append(area)
	## Find the shape owner ID using the index
	#var shape_owner_id: int = shape_find_owner(local_shape_index)
	## Get the actual CollisionShape2D node from that owner
	##var shape_node: CollisionShape2D = shape_owner_get_owner(shape_owner_id)
	#shape_hit_something.emit(self, shape_owner_id, area)
	shape_hit_something.emit(self, local_shape_index, area)
	area.contacted(self, get_rid(), local_shape_index)
	
func _draw() -> void:
	if _debug:
		_draw_debug_shapes()
	
func _draw_debug_shapes() -> void:
	for i: int in range(shapes_array.size()):
		var shape: CollisionShape2D = shapes_array[i]
		if shape is not CollisionShape2D:
			continue
		if shape.disabled:
			continue
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.corner_detail = 8
		style_box.set_corner_radius_all(20)
		style_box.bg_color = Color.RED
		style_box.bg_color.a = 0.6
		var height: float = shape.shape.height if shape.shape is CapsuleShape2D else 4.0
		var radius: float = shape.shape.radius
		var pos: Vector2 = shape.position
		var rect: Rect2 = Rect2(pos, Vector2(radius*2.0, height))
		var angle_rad: float = deg_to_rad(shape.rotation_degrees)
		draw_set_transform(pos, angle_rad, Vector2.ONE)
		var centered_rect = Rect2(-rect.size / 2, rect.size)
		draw_style_box(style_box, centered_rect)
		draw_set_transform(pos, 0.0, Vector2.ONE)
		var line_col: Color = Color.WHITE
		line_col.a = 0.6
		draw_line(Vector2.ZERO, shape_angle_vis_arr[i], line_col, 0.5)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
