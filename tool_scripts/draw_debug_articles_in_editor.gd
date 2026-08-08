@tool
class_name DrawDebugArticlesInEditor extends Node2D

var articles: Array[Article]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		if %Articles:
			for _article in %Articles.get_children():
				articles.append(_article)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	
func _draw() -> void:
	if Engine.is_editor_hint():
		for a: Article in articles:
			if !a.debug:
				continue
			var dimensions: EcbStatsRes = a.entity.ecb_stats
			var top_pos: Vector2 = a.global_position + Vector2(0.0, -dimensions.top_span)
			var left_pos: Vector2 = a.global_position + Vector2(-dimensions.left_span, 0.0)
			var right_pos: Vector2 = a.global_position + Vector2(dimensions.right_span, 0.0)
			var bottom_pos: Vector2 = a.global_position + Vector2(0.0, dimensions.bottom_span)
			## draw ecb boundaries
			draw_line(top_pos, left_pos, Color.CORAL, 1.0)
			draw_line(left_pos, bottom_pos, Color.CORAL, 1.0)
			draw_line(bottom_pos, right_pos, Color.CORAL, 1.0)
			draw_line(right_pos, top_pos, Color.CORAL, 1.0)
			## draw hurtboxes
			var debug_vis: StyleBoxFlat = StyleBoxFlat.new()
			debug_vis.set_corner_radius_all(20)
			debug_vis.corner_detail = 8
			debug_vis.bg_color = Color.DARK_GOLDENROD
			debug_vis.bg_color.a = 0.6
			for shape: CollisionShape2D in a.hurtbox.get_children():
				var height: float = shape.shape.height if shape.shape is CapsuleShape2D else 4.0
				var radius: float = shape.shape.radius
				draw_style_box(debug_vis, Rect2(a.global_position + Vector2(-radius, -height*0.5) + shape.position, Vector2(radius*2.0, height)))
