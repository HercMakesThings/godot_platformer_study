class_name EnvironmentCollisionDiamond extends Area2D

@onready var shape: CollisionShape2D = %shape

@export var DEFAULT_ECB_STATS: EcbStatsRes

var article: Article

var dimensions: EcbStatsRes

var last_global_position: Vector2

enum BoxPoint{ TOP, RIGHT, BOTTOM, LEFT, CENTER }
var _bounding_box: Dictionary[BoxPoint, Vector2]

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	last_global_position = global_position
	
func init_stats(stats: EcbStatsRes) -> void:
	set_shape(stats)
	
func bind(_article: Article) -> void:
	article = _article
	set_shape(article.entity.ecb_stats)
	
#func tick(article: Article, delta: float) -> void:
func tick(delta: float) -> void:
	## Request the engine to call _draw() on the next frame
	queue_redraw()
	## Check for collisions at the beginning of the physics frame (Article calls tick() first)
	if dimensions.CONTINUOUS_COLLISION_DETECTION:
		update_ecb_rays(delta)
	## check for collisions again at the end of the physics frame
	call_deferred("update_ecb_rays", delta)
	## update last global position for offset vectors
	call_deferred("update_last_position")
	
func _on_area_entered(_area: Area2D) -> void:
	pass
	
func _draw() -> void:
	if !article:
		return
	if article.debug:
		_draw_debug_ecb()
	
func update_ecb_rays(delta: float) -> void:
		## Get offset and projected velocity vectors
		var velocity_vec: Vector2 = global_position - last_global_position
		var velocity_projection: Vector2 = article.entity.body_vel * delta
		## Update bounding box vector points (in global space) for raycast queries
		_bounding_box.set(BoxPoint.TOP, global_position + Vector2(0.0, -dimensions.top_span))
		_bounding_box.set(BoxPoint.RIGHT, global_position + Vector2(dimensions.right_span, 0.0))
		_bounding_box.set(BoxPoint.BOTTOM, global_position + Vector2(0.0, dimensions.bottom_span))
		_bounding_box.set(BoxPoint.LEFT, global_position + Vector2(-dimensions.left_span, 0.0))
		_bounding_box.set(BoxPoint.CENTER, global_position)
		###### query physics state
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		## cast rays for each point in the diamond and handle collisions
		for k: BoxPoint in _bounding_box.keys():
			if k == BoxPoint.CENTER:
				return
			var _pos: Vector2 = _bounding_box.get(k)
			var _collider: Object = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _bounding_box.get(BoxPoint.CENTER), _pos),
				"Wall" if (k == BoxPoint.LEFT || k == BoxPoint.RIGHT) else "Floor",
				k == BoxPoint.BOTTOM
			)
			if !_collider:
				_collider = _get_ecb_collider_from_query(
					_cast_ecb_ray(space_state, _pos, _pos - velocity_vec),
					"Wall" if (k == BoxPoint.LEFT || k == BoxPoint.RIGHT) else "Floor",
					k == BoxPoint.BOTTOM
				)
			if !_collider:
				_collider = _get_ecb_collider_from_query(
					_cast_ecb_ray(space_state, _pos, _pos + velocity_projection),
					"Wall" if (k == BoxPoint.LEFT || k == BoxPoint.RIGHT) else "Floor",
					k == BoxPoint.BOTTOM
				)
			match k:
				BoxPoint.TOP:
					if _collider:
						if article.entity.body_vel.y < 0.0:
							article.position.y = _collider.position.y + (_collider.collision_shape.size.y*0.5) + dimensions.height
							article.entity.body_vel.y = 0.0 ## may or may not need this
				BoxPoint.RIGHT:
					if _collider:
						if article.entity.body_vel.x > 0.0:
							article.position.x = _collider.position.x - (_collider.collision_shape.size.x*0.5) - dimensions.right_span
							article.entity.body_vel.x = 0.0
				BoxPoint.BOTTOM:
					if _collider && _collider is PlatformNew && (article.entity.direction.y <= -article.entity.deadzone && article.entity.can_move):
						_collider = null
						return ## early return to allow for dropping through platforms
					article.entity.body_on_ground = _collider != null
					if _collider:
						article.entity.is_on_platform = _collider is PlatformNew
						if article.entity.body_vel.y >= 0.0:
							article.entity.body_vel.y = 0.0
							article.position.y = _collider.position.y - (_collider.collision_shape.size.y*0.5) + -dimensions.bottom_span
				BoxPoint.LEFT:
					if _collider:
						if article.entity.body_vel.x < 0.0:
							article.position.x = _collider.position.x + (_collider.collision_shape.size.x*0.5) + dimensions.left_span
							article.entity.body_vel.x = 0.0
				_:
					continue
			_collider = null
		###### query physics state END
	
func _cast_ecb_ray(space_state: PhysicsDirectSpaceState2D, origin: Vector2, end: Vector2) -> Dictionary:
	var query = PhysicsRayQueryParameters2D.create(origin, end, collision_mask)
	query.collide_with_areas = true
	query.exclude = [self]
	return space_state.intersect_ray(query)
	
func _get_ecb_collider_from_query(cast: Dictionary, terrain_type: String, is_bottom_ray: bool = false) -> Object:
	if !cast.has("collider"):
		return null
	var collider: Object = cast["collider"]
	if collider is not TerrainArea2D:
		if is_bottom_ray:
			if collider is not PlatformNew:
				return null
		else:
			return null
	if collider is not PlatformNew && collider.type != terrain_type:
		return null
	if is_bottom_ray:
		var coll_point: Vector2 = cast.position
		if collider is PlatformNew && coll_point.distance_to(global_position + Vector2(0.0, dimensions.bottom_span)) >= dimensions.COLLISION_POINT_THRESHOLD:
			return null
	return collider
	
func set_shape(stats: EcbStatsRes) -> void:
	dimensions = stats
	shape.shape.points = PackedVector2Array([
		Vector2(0.0, -stats.top_span),
		Vector2(stats.right_span, 0.0),
		Vector2(0.0, stats.bottom_span),
		Vector2(-stats.left_span, 0.0)
	])
	
func set_shape_to_default():
	set_shape(DEFAULT_ECB_STATS)
	
func update_last_position():
	last_global_position = global_position
	
func _draw_debug_ecb() -> void:
	var velocity_vec: Vector2 = global_position - last_global_position
	var top_pos: Vector2 = Vector2(0.0, -dimensions.top_span)
	var left_pos: Vector2 = Vector2(-dimensions.left_span, 0.0)
	var right_pos: Vector2 = Vector2(dimensions.right_span, 0.0)
	var bottom_pos: Vector2 = Vector2(0.0, dimensions.bottom_span)
	var physics_delta = get_physics_process_delta_time()
	var velocity_projection: Vector2 = article.entity.body_vel * physics_delta
	#var top_color: Color = Color.GREEN if top_collider && top_collider.position else Color.RED
	# Fetch the physics frame delta (usually 0.016667 for 60 FPS)
	## draw ecb boundaries
	draw_line(top_pos, left_pos, Color.CORAL, 1.0)
	draw_line(left_pos, bottom_pos, Color.CORAL, 1.0)
	draw_line(bottom_pos, right_pos, Color.CORAL, 1.0)
	draw_line(right_pos, top_pos, Color.CORAL, 1.0)
	## draw TOP offset & projection vectors
	draw_line(top_pos, top_pos - velocity_vec, Color.GREEN, 1.0)
	draw_line(top_pos, top_pos + velocity_projection, Color.GREEN, 1.0)
	## draw RIGHT offset & projection vectors
	draw_line(right_pos, right_pos - velocity_vec, Color.GREEN, 1.0)
	draw_line(right_pos, right_pos + velocity_projection, Color.GREEN, 1.0)
	## draw LEFT offset & projection vectors
	draw_line(left_pos, left_pos - velocity_vec, Color.GREEN, 1.0)
	draw_line(left_pos, left_pos + velocity_projection, Color.GREEN, 1.0)
	## draw BOTTOM offset & projection vectors
	draw_line(bottom_pos, bottom_pos + -velocity_vec, Color.GREEN, 1.0)
	draw_line(bottom_pos, bottom_pos + velocity_projection, Color.GREEN, 1.0)
