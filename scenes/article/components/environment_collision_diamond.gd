class_name EnvironmentCollisionDiamond extends Area2D

@onready var shape: CollisionShape2D = %shape

@export var DEFAULT_ECB_STATS: EcbStatsRes

var dimensions: EcbStatsRes

var last_global_position: Vector2

var right_collider: Object = null
var left_collider: Object = null
var top_collider: Object = null
var bottom_collider: Object = null

var _center_pos: Vector2
var _right_pos: Vector2
var _left_pos: Vector2
var _top_pos: Vector2

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	last_global_position = global_position
	
func init_stats(stats: EcbStatsRes) -> void:
	set_shape(stats)

func tick(article: Article, delta: float) -> void:
	## Check for collisions at the beginning of the physics frame (Article calls tick() first)
	if dimensions.CONTINUOUS_COLLISION_DETECTION:
		update_ecb_rays(article, delta)
	## check for collisions again at the end of the physics frame
	call_deferred("update_ecb_rays", article, delta)
	## update last global position for offset vectors
	call_deferred("update_last_position")
	
func _on_area_entered(_area: Area2D) -> void:
	pass
	
func update_ecb_rays(article: Article, delta: float) -> void:
		## Get offset and projected velocity vectors
		var velocity_vec: Vector2 = global_position - last_global_position
		var velocity_projection: Vector2 = article.entity.body_vel * delta
		## Update ecb corners in global space (bottom currently == global_position)
		_center_pos = global_position + Vector2(0.0, -dimensions.center)
		_left_pos = global_position + Vector2(-dimensions.left_span, -dimensions.center)
		_right_pos = global_position + Vector2(dimensions.right_span, -dimensions.center)
		_top_pos = global_position + Vector2(0.0, -dimensions.height)
		###### query physics state
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		### left
		left_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, _center_pos, _left_pos),
			"Wall"
		)
		if !left_collider:
			left_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _left_pos, _left_pos - velocity_vec),
				"Wall"
			)
		if !left_collider:
			left_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _left_pos, _left_pos + velocity_projection),
				"Wall"
			)
		if left_collider:
			if article.entity.body_vel.x < 0.0:
				article.position.x = left_collider.position.x + (left_collider.collision_shape.size.x*0.5) + dimensions.left_span
				article.entity.body_vel.x = 0.0
		### right
		right_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, _center_pos, _right_pos),
			"Wall"
		)
		if !right_collider:
			right_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _right_pos, _right_pos - velocity_vec),
				"Wall"
			)
		if !right_collider:
			right_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _right_pos, _right_pos + velocity_projection),
				"Wall"
			)
		if right_collider:
			if article.entity.body_vel.x > 0.0:
				article.position.x = right_collider.position.x - (right_collider.collision_shape.size.x*0.5) - dimensions.right_span
				article.entity.body_vel.x = 0.0
		### top
		top_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, _center_pos, _top_pos),
			"Floor"
		)
		if !top_collider:
			top_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _top_pos, _top_pos - velocity_vec),
				"Floor"
			)
		if !top_collider:
			top_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, _top_pos, _top_pos + velocity_projection),
				"Floor"
			)
		if top_collider:
			if article.entity.body_vel.y < 0.0:
				article.position.y = top_collider.position.y + (top_collider.collision_shape.size.y*0.5) + dimensions.height
				article.entity.body_vel.y = 0.0 ## may or may not need this
		### bottom
		bottom_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, _center_pos, global_position),
			"Floor",
			true
		)
		if !bottom_collider:
			bottom_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position, global_position - velocity_vec),
				"Floor",
				true
			)
		if !bottom_collider:
			bottom_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position, global_position + velocity_projection),
				"Floor",
				true
			)
		if bottom_collider is PlatformNew && (article.entity.direction.y <= -article.entity.deadzone && article.entity.can_move):
			return ## early return to allow for dropping through platforms
		article.entity.body_on_ground = bottom_collider != null
		if bottom_collider:
			article.entity.is_on_platform = bottom_collider is PlatformNew
			if article.entity.body_vel.y >= 0.0:
				article.entity.body_vel.y = 0.0
				article.position.y = bottom_collider.position.y - (bottom_collider.collision_shape.size.y*0.5)
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
		if collider is PlatformNew && coll_point.distance_to(global_position) >= dimensions.COLLISION_POINT_THRESHOLD:
			return null
	return collider
	
func set_shape(stats: EcbStatsRes) -> void:
	dimensions = stats
	shape.shape.points = PackedVector2Array([
		Vector2(0, -stats.height),
		Vector2(stats.right_span, -stats.center),
		Vector2.ZERO,
		Vector2(-stats.left_span, -stats.center)
	])
	
func set_shape_to_default():
	set_shape(DEFAULT_ECB_STATS)
	
func update_last_position():
	last_global_position = global_position
