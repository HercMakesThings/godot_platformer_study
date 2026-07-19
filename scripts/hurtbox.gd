extends Area2D
class_name Hurtbox

#signal hurtbox_hit(hitbox: Hitbox)

var article: Article

signal hurtbox_was_hit(hitbox: Hitbox, area_rid: RID, area_shape_index: int)

func _ready() -> void:
	monitoring = false
	if get_parent() is Article:
		article = get_parent()
	
func contacted(area: Area2D, area_rid: RID, area_shape_index: int) -> void:
	hurtbox_was_hit.emit(area, area_rid, area_shape_index)
	
func _draw() -> void:
	if !article:
		return
	if article.debug:
		_draw_debug_shapes()
		
func _draw_debug_shapes() -> void:
	var debug_vis: StyleBoxFlat = StyleBoxFlat.new()
	debug_vis.set_corner_radius_all(20)
	debug_vis.corner_detail = 8
	debug_vis.bg_color = Color.DARK_GOLDENROD
	debug_vis.bg_color.a = 0.6
	var shape: CollisionShape2D = get_child(0)
	var height: float = shape.shape.height if shape.shape is CapsuleShape2D else 4.0
	var radius: float = shape.shape.radius
	draw_style_box(debug_vis, Rect2(Vector2(-radius, -height), Vector2(radius*2.0, height)))
	
func _physics_process(_delta: float) -> void:
	#if article.debug:
		queue_redraw()
	
#func _on_hurtbox_area_entered(area: Area2D) -> void:
	#if area.is_in_group("atk_hitbox_group") and area is Hitbox:
		##print(area.dmg)
		##hurtbox_hit.emit(area)
		#pass
#
#func _on_hurtbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int):
	#if area is not Hitbox:
		#return
	### return if hitbox is owned by this entity
	#if area.owner_hurtbox.get_rid() == get_rid():
		#return
	#if area.collided_hurtboxes.has(self):
		#return
	#if area is Hitbox && area.owner_hurtbox.get_rid() != get_rid():
		#hurtbox_was_hit.emit(area, area_rid, area_shape_index)
	
