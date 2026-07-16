class_name EnvironmentCollisionBody extends Area2D

@onready var top: RayCast2D = %top
@onready var right: RayCast2D = %right
@onready var bottom: RayCast2D = %bottom
@onready var left: RayCast2D = %left

@onready var offset_bottom: RayCast2D = %offset_bottom
@onready var offset_top: RayCast2D = %offset_top
@onready var offset_left: RayCast2D = %offset_left
@onready var offset_right: RayCast2D = %offset_right

@onready var bottom_detector: RayCast2D = %bottom_detector
@onready var top_detector: RayCast2D = %top_detector
@onready var left_detector: RayCast2D = %left_detector
@onready var right_detector: RayCast2D = %right_detector


@onready var shape: CollisionShape2D = %shape

@export var height: float = 24.0
@export var center: float = 16.0
@export var left_span: float = 10.0
@export var right_span: float = 10.0

@export var COLLISION_POINT_THRESHOLD: float = 4.0

@export var DEFAULT_ECB_STATS: EcbStatsRes

var dimensions: EcbStatsRes

var last_global_position: Vector2

var bottom_detected: bool
var left_detected: bool
var right_detected: bool
var top_detected: bool

var right_collider: Object = null
var left_collider: Object = null
var top_collider: Object = null
var bottom_collider: Object = null

func _ready() -> void:
	#set_shape(center, height, left_span, right_span)
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
	#(
		#func():
			#bottom.force_raycast_update()
			#if area is PlatformNew:
				#if get_parent().entity.body_vel.y > 0:
					#print("test!")
					#get_parent().position.y = area.position.y - (area.shape.size.y*0.5)
	#).call_deferred()
	pass
	#if area is TerrainArea2D:
			##print("sunk!")
		##if !bottom.is_colliding():
			#get_parent().entity.body_vel.y = 0
			#get_parent().velocity.y = 0
			#get_parent().position.y = area.position.y
	
func update_ecb_rays(article: Article, delta: float) -> void:
		#bottom.force_raycast_update()
		#top.force_raycast_update()
		#left.force_raycast_update()
		#right.force_raycast_update()
		
		var velocity_vec: Vector2 = global_position - last_global_position
		#offset_bottom.target_position = offset_bottom.to_local(global_position - velocity_vec)
		#offset_top.target_position = offset_top.to_local(global_position - velocity_vec) + offset_top.position
		#offset_left.target_position = offset_left.to_local(global_position - velocity_vec) + offset_left.position
		#offset_right.target_position = offset_right.to_local(global_position - velocity_vec) + offset_right.position
		
		#offset_bottom.force_raycast_update()
		#offset_top.force_raycast_update()
		#offset_left.force_raycast_update()
		#offset_right.force_raycast_update()
		
		var velocity_projection: Vector2 = article.entity.body_vel * delta
		#bottom_detector.target_position = bottom_detector.to_local(global_position + velocity_projection)
		#top_detector.target_position = top_detector.to_local(global_position + velocity_projection) + offset_top.position
		#left_detector.target_position = left_detector.to_local(global_position + velocity_projection) + offset_left.position
		#right_detector.target_position = right_detector.to_local(global_position + velocity_projection) + offset_right.position
		
		#bottom_detector.force_raycast_update()
		#top_detector.force_raycast_update()
		#left_detector.force_raycast_update()
		#right_detector.force_raycast_update()
		
		###### query physics state experiment
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		### left
		left_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.center), global_position + Vector2(-dimensions.left_span, -dimensions.center)),
			"Wall"
		)
		if !left_collider:
			left_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(-dimensions.left_span, -dimensions.center), global_position + Vector2(-dimensions.left_span, -dimensions.center) - velocity_vec),
				"Wall"
			)
		if !left_collider:
			left_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(-dimensions.left_span, -dimensions.center), global_position + Vector2(-dimensions.left_span, -dimensions.center) + velocity_projection),
				"Wall"
			)
		if left_collider:
			if article.entity.body_vel.x < 0.0:
				article.position.x = left_collider.position.x + (left_collider.collision_shape.size.x*0.5) + dimensions.left_span
				article.entity.body_vel.x = 0.0
		### right
		right_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.center), global_position + Vector2(dimensions.right_span, -dimensions.center)),
			"Wall"
		)
		if !right_collider:
			right_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(dimensions.right_span, -dimensions.center), global_position + Vector2(dimensions.right_span, -dimensions.center) - velocity_vec),
				"Wall"
			)
		if !right_collider:
			right_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(dimensions.right_span, -dimensions.center), global_position + Vector2(dimensions.right_span, -dimensions.center) + velocity_projection),
				"Wall"
			)
		if right_collider:
			if article.entity.body_vel.x > 0.0:
				article.position.x = right_collider.position.x - (right_collider.collision_shape.size.x*0.5) - dimensions.right_span
				article.entity.body_vel.x = 0.0
		### top
		top_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.center), global_position + Vector2(0.0, -dimensions.height)),
			"Floor"
		)
		if !top_collider:
			top_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.height), global_position + Vector2(0.0, -dimensions.height) - velocity_vec),
				"Floor"
			)
		if !top_collider:
			top_collider = _get_ecb_collider_from_query(
				_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.height), global_position + Vector2(0.0, -dimensions.height) + velocity_projection),
				"Floor"
			)
		if top_collider:
			if article.entity.body_vel.y < 0.0:
				article.position.y = top_collider.position.y + (top_collider.collision_shape.size.y*0.5) + dimensions.height
				article.entity.body_vel.y = 0.0 ## may or may not need this
		### bottom
		bottom_collider = _get_ecb_collider_from_query(
			_cast_ecb_ray(space_state, global_position + Vector2(0.0, -dimensions.center), global_position),
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
		###### end experiment
		
		###### handle right side collisions
		#right_collider = _get_ecb_collider(right, "Wall")
		#if !right_collider:
			#right_collider = _get_ecb_collider(offset_right, "Wall")
		#if !right_collider:
			#right_collider = _get_ecb_collider(right_detector, "Wall")
		#if right_collider:
			#if article.entity.body_vel.x > 0.0:
				#article.position.x = right_collider.position.x - (right_collider.collision_shape.size.x*0.5) - dimensions.right_span
				#article.entity.body_vel.x = 0.0
		###### END right side collisions
		###### handle left side collisions
		#left_collider = _get_ecb_collider(left, "Wall")
		#if !left_collider:
			#left_collider = _get_ecb_collider(offset_left, "Wall")
		#if !left_collider:
			#left_collider = _get_ecb_collider(left_detector, "Wall")
		#if left_collider:
			#if article.entity.body_vel.x < 0.0:
				#article.position.x = left_collider.position.x + (left_collider.collision_shape.size.x*0.5) + dimensions.left_span
				#article.entity.body_vel.x = 0.0
		###### END left side collisions
		###### handle top side collisions
		#top_collider = _get_ecb_collider(top, "Floor")
		#if !top_collider:
			#top_collider = _get_ecb_collider(offset_top, "Floor")
		#if !top_collider:
			#top_collider = _get_ecb_collider(top_detector, "Floor")
		#if top_collider:
			#if article.entity.body_vel.y < 0.0:
				#article.position.y = top_collider.position.y + (top_collider.collision_shape.size.y*0.5) + dimensions.height
				#article.entity.body_vel.y = 0.0 ## may or may not need this
		###### END top side collisions
		###### handle bottom collisions
		#bottom_collider = _get_ecb_collider(bottom, "Floor", true)
		#if !bottom_collider:
			#bottom_collider = _get_ecb_collider(offset_bottom, "Floor", true)
		#if !bottom_collider:
			#bottom_collider = _get_ecb_collider(bottom_detector, "Floor", true)
		#if bottom_collider is PlatformNew && (article.entity.direction.y <= -article.entity.deadzone && article.entity.can_move):
			#return ## early return to allow for dropping through platforms
		#article.entity.body_on_ground = bottom_collider != null
		#if bottom_collider:
			#article.entity.is_on_platform = bottom_collider is PlatformNew
			#if article.entity.body_vel.y >= 0.0:
				#article.entity.body_vel.y = 0.0
				#article.position.y = bottom_collider.position.y - (bottom_collider.collision_shape.size.y*0.5)
		###### END bottom collisions
		
		#if left_detected && (left_detector.is_colliding() && left_detector.get_collider() is TerrainArea2D && left_detector.get_collider().type == "Wall"):
			#article.position.x = left_detector.get_collider().position.x + (left_detector.get_collider().collision_shape.size.x*0.5) + dimensions.left_span
			#if article.entity.body_vel.x < 0.0:
				#article.entity.body_vel.x = 0.0
		#if right_detected && (right_detector.is_colliding() && right_detector.get_collider() is TerrainArea2D && right_detector.get_collider().type == "Wall"):
			#article.position.x = right_detector.get_collider().position.x - (right_detector.get_collider().collision_shape.size.x*0.5) - dimensions.right_span
			#if article.entity.body_vel.x > 0.0:
				#article.entity.body_vel.x = 0.0
		#if top_detected && (top_detector.is_colliding() && top_detector.get_collider() is TerrainArea2D && top_detector.get_collider().type == "Floor"):
			#article.position.y = top_detector.get_collider().position.y + (top_detector.get_collider().collision_shape.size.y*0.5) + dimensions.height
			#if article.entity.body_vel.y < 0.0:
				#article.entity.body_vel.y = 0.0
		
		#if (right.is_colliding() && (right.get_collider() is TerrainArea2D && right.get_collider().type == "Wall")):
				#if article.entity.body_vel.x > 0.0:
					#article.entity.body_vel.x = 0.0
				#article.position.x = right.get_collider().position.x - (right.get_collider().collision_shape.size.x*0.5) - dimensions.right_span
		#elif (offset_right.is_colliding() && (offset_right.get_collider() is TerrainArea2D && offset_right.get_collider().type == "Wall")):
				#if offset_right.target_position.x <= 0.0:
					#if article.entity.body_vel.x > 0.0:
						#article.entity.body_vel.x = 0.0
					#article.position.x = offset_right.get_collider().position.x - (offset_right.get_collider().collision_shape.size.x*0.5) - dimensions.right_span
		#elif (right_detector.is_colliding() && (right_detector.get_collider() is TerrainArea2D && right_detector.get_collider().type == "Wall")):
			#if article.entity.body_vel.x > 0.0:
				#right_detected = true
		#else:
			#right_detected = false
				
		#if (left.is_colliding() && (left.get_collider() is TerrainArea2D && left.get_collider().type == "Wall")):
				#if article.entity.body_vel.x < 0.0:
					#article.entity.body_vel.x = 0.0
				#article.position.x = left.get_collider().position.x + (left.get_collider().collision_shape.size.x*0.5) + dimensions.left_span
		#elif (offset_left.is_colliding() && (offset_left.get_collider() is TerrainArea2D && offset_left.get_collider().type == "Wall")):
				#if offset_left.target_position.x >= 0.0:
					#if article.entity.body_vel.x < 0.0:
						#article.entity.body_vel.x = 0.0
					#article.position.x = offset_left.get_collider().position.x + (offset_left.get_collider().collision_shape.size.x*0.5) + dimensions.left_span
		#elif (left_detector.is_colliding() && (left_detector.get_collider() is TerrainArea2D && left_detector.get_collider().type == "Wall")):
				#if article.entity.body_vel.x < 0.0:
					#left_detected = true
		#else:
			#left_detected = false
			
		#if (top.is_colliding() && top.get_collider() is TerrainArea2D):
			#if article.entity.body_vel.y < 0:
				#article.entity.body_vel.y = 0.0
				#article.position.y = top.get_collider().position.y + (top.get_collider().collision_shape.size.y*0.5) + dimensions.height
		#elif (offset_top.is_colliding() && offset_top.get_collider() is TerrainArea2D):
			#if article.entity.body_vel.y < 0:
				#article.entity.body_vel.y = 0.0
				#article.position.y = offset_top.get_collider().position.y + (offset_top.get_collider().collision_shape.size.y*0.5) + dimensions.height
		#elif (top_detector.is_colliding() && (top_detector.get_collider() is TerrainArea2D && top_detector.get_collider().type == "Floor")):
			#if article.entity.body_vel.y <= 0.0:
					#top_detected = true
		#else:
			#top_detected = false
		
		#bottom.enabled = article.entity.body_vel.y >= 0
			#
		#var coll_point: Vector2 = bottom.get_collision_point()
		#if (
			#bottom_detected &&
			#(bottom_detector.is_colliding() && 
			#((bottom_detector.get_collider() is TerrainArea2D && bottom_detector.get_collider().type == "Floor") ||
			#(bottom_detector.get_collider() is PlatformNew && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD)))
		#):
			#article.position.y = bottom_detector.get_collider().position.y - (bottom_detector.get_collider().collision_shape.size.y*0.5)
			#article.entity.body_vel.y = 0.0
		#if ( bottom.is_colliding() &&
			#( (bottom.get_collider() is TerrainArea2D && bottom.get_collider().type == "Floor") ||
				#(  bottom.get_collider() is PlatformNew &&
					#coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD
				#)
			#)
		#):
			#if article.entity.body_vel.y >= 0.0:
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = bottom.get_collider() is PlatformNew
				#article.entity.body_vel.y = 0.0
			#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		#elif (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || (offset_bottom.get_collider() is TerrainArea2D && offset_bottom.get_collider().type == "Floor"))):
				#if article.entity.body_vel.y >= 0.0:
					#article.entity.body_on_ground = true
					#article.entity.is_on_platform = offset_bottom.get_collider() is PlatformNew
					#article.entity.body_vel.y = 0.0
				#if offset_bottom.target_position.y <= 0.0:
					#article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		#elif (bottom_detector.is_colliding() && (bottom_detector.get_collider() is PlatformNew || (bottom_detector.get_collider() is TerrainArea2D && bottom_detector.get_collider().type == "Floor"))):
				#if article.entity.body_vel.y >= 0.0:
					#bottom_detected = true
		#else:
			#article.entity.body_on_ground = false
			#article.entity.is_on_platform = false
			#bottom_detected = false
		
func _is_ecb_ray_colliding(ray: RayCast2D, terrain_type: String, is_bottom_ray: bool = false) -> bool:
	if !ray.is_colliding():
		return false
	if ray.get_collider() is not TerrainArea2D:
		if is_bottom_ray:
			if ray.get_collider() is not PlatformNew:
				return false
		return false
	if ray.get_collider().type != terrain_type:
		return false
	if is_bottom_ray:
		var coll_point: Vector2 = ray.get_collision_point()
		if ray.get_collider() is PlatformNew && coll_point.distance_to(ray.global_position + ray.target_position) >= COLLISION_POINT_THRESHOLD:
			return false
	return true
	
func _get_ecb_collider(ray: RayCast2D, terrain_type: String, is_bottom_ray: bool = false) -> Object:
	if !ray.is_colliding():
		return null
	var collider: Object = ray.get_collider()
	if collider is not TerrainArea2D:
		if is_bottom_ray:
			if collider is not PlatformNew:
				return null
		else:
			return null
	if collider is not PlatformNew && collider.type != terrain_type:
		return null
	if is_bottom_ray:
		var coll_point: Vector2 = ray.get_collision_point()
		if collider is PlatformNew && coll_point.distance_to(ray.global_position + ray.target_position) >= COLLISION_POINT_THRESHOLD:
			return null
	return collider
	
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
		if collider is PlatformNew && coll_point.distance_to(global_position) >= COLLISION_POINT_THRESHOLD:
			return null
	return collider
	
#func set_shape(c: float, h: float, l: float, r: float) -> void:
	#top.position = Vector2(0.0, -c)
	#left.position = Vector2(0.0, -c)
	#right.position = Vector2(0.0, -c)
	#bottom.position = Vector2(0.0, -c)
	#
	#top.target_position = Vector2(0, -h+c)
	#left.target_position = Vector2(-l, 0.0)
	#right.target_position = Vector2(r, 0.0)
	#bottom.target_position = Vector2(0.0, c)
	#
	#offset_bottom.position = Vector2.ZERO
	#offset_top.position = top.position + top.target_position
	#offset_left.position = left.position + left.target_position
	#offset_right.position = right.position + right.target_position
	#
	#offset_bottom.target_position = Vector2.ZERO
	#offset_top.target_position = Vector2.ZERO
	#offset_left.target_position = Vector2.ZERO
	#offset_right.target_position = Vector2.ZERO
	#
	#bottom_detector.position = Vector2.ZERO
	#top_detector.position = top.position + top.target_position
	#left_detector.position = left.position + left.target_position
	#right_detector.position = right.position + right.target_position
	#
	#bottom_detector.target_position = Vector2.ZERO
	#top_detector.target_position = Vector2.ZERO
	#left_detector.target_position = Vector2.ZERO
	#right_detector.target_position = Vector2.ZERO
func set_shape(stats: EcbStatsRes) -> void:
	dimensions = stats
	
	top.position = Vector2(0.0, -stats.center)
	left.position = Vector2(0.0, -stats.center)
	right.position = Vector2(0.0, -stats.center)
	bottom.position = Vector2(0.0, -stats.center)
	
	top.target_position = Vector2(0, -stats.height+stats.center)
	left.target_position = Vector2(-stats.left_span, 0.0)
	right.target_position = Vector2(stats.right_span, 0.0)
	bottom.target_position = Vector2(0.0, stats.center)
	
	offset_bottom.position = Vector2.ZERO
	offset_top.position = top.position + top.target_position
	offset_left.position = left.position + left.target_position
	offset_right.position = right.position + right.target_position
	
	offset_bottom.target_position = Vector2.ZERO
	offset_top.target_position = Vector2.ZERO
	offset_left.target_position = Vector2.ZERO
	offset_right.target_position = Vector2.ZERO
	
	bottom_detector.position = Vector2.ZERO
	top_detector.position = top.position + top.target_position
	left_detector.position = left.position + left.target_position
	right_detector.position = right.position + right.target_position
	
	bottom_detector.target_position = Vector2.ZERO
	top_detector.target_position = Vector2.ZERO
	left_detector.target_position = Vector2.ZERO
	right_detector.target_position = Vector2.ZERO
	
	shape.shape.points = PackedVector2Array([
		Vector2(0, -stats.height),
		Vector2(stats.right_span, -stats.center),
		Vector2.ZERO,
		Vector2(-stats.left_span, -stats.center)
	])
	
func set_shape_to_default():
	#set_shape(center, height, left_span, right_span)
	set_shape(DEFAULT_ECB_STATS)
	
func update_last_position():
	last_global_position = global_position
	
