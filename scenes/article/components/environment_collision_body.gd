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
@export var width: float = 20.0

@export var COLLISION_POINT_THRESHOLD: float = 4.0

var last_global_position: Vector2

var bottom_detected: bool
var left_detected: bool
var right_detected: bool
var top_detected: bool

func _ready() -> void:
	top.position = Vector2(0, -center)
	left.position = Vector2(0, -center)
	right.position = Vector2(0, -center)
	bottom.position = Vector2(0, -center)
	#bottom.position = Vector2(0, -1.0)
	
	
	top.target_position = Vector2(0, -height+center)
	left.target_position = Vector2(-width*0.5, 0)
	right.target_position = Vector2(width*0.5, 0)
	bottom.target_position = Vector2(0, center)
	#bottom.target_position = Vector2(0, 1.0)
	
	offset_bottom.position = Vector2(0, 0)
	offset_top.position = top.position + top.target_position
	offset_left.position = left.position + left.target_position
	offset_right.position = right.position + right.target_position
	
	offset_bottom.target_position = Vector2(0.0, 0.0)
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
		Vector2(0, -height),
		Vector2(width*0.5, -center),
		Vector2.ZERO,
		Vector2(-width*0.5, -center)
	])
	area_entered.connect(_on_area_entered)
	#offset_bottom.target_position = Vector2(0.0, 40.0)
	last_global_position = global_position

func tick(article: Article, delta: float) -> void:
	
	update_ecb_rays(article, delta)
	
	call_deferred("update_ecb_rays", article, delta)
	
	#(func():
		#bottom.force_raycast_update()
		#top.force_raycast_update()
		#left.force_raycast_update()
		#right.force_raycast_update()
		#
		#var velocity_vec: Vector2 = global_position - last_global_position
		#offset_bottom.target_position = offset_bottom.to_local(global_position - velocity_vec)
		#offset_top.target_position = offset_top.to_local(global_position - velocity_vec) + offset_top.position
		#offset_left.target_position = offset_left.to_local(global_position - velocity_vec) + offset_left.position
		#offset_right.target_position = offset_right.to_local(global_position - velocity_vec) + offset_right.position
		#
		#offset_bottom.force_raycast_update()
		#offset_top.force_raycast_update()
		#offset_left.force_raycast_update()
		#offset_right.force_raycast_update()
		#
		#print("offset left target pos: " + str(offset_left.target_position))
		#if offset_left.is_colliding():
			#print("terrain type: " + str(offset_left.get_collider()))
		##if (right.is_colliding() && right.get_collider() is TerrainArea2D):
				##article.entity.body_vel.x = 0.0
				##article.position.x = right.get_collider().position.x - (right.get_collider().collision_shape.size.x*0.5) - (width*0.5)
		##elif (offset_right.is_colliding() && offset_right.get_collider() is TerrainArea2D):
				##article.entity.body_vel.x = 0.0
				##if offset_right.target_position.x < 0.0:
					##article.position.x = offset_right.get_collider().position.x - (offset_right.get_collider().collision_shape.size.x*0.5) - (width*0.5)
		#if (left.is_colliding() && (left.get_collider() is TerrainArea2D && left.get_collider().type == "Wall")):
		##if (left.is_colliding() && left.get_collider() is TerrainArea2D) || (offset_left.is_colliding() && offset_left.get_collider() is TerrainArea2D):
				#if article.entity.body_vel.x < 0.0:
					#article.entity.body_vel.x = 0.0
				#article.position.x = left.get_collider().position.x + (left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
				##if left.is_colliding():
					##article.position.x = left.get_collider().position.x + (left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
				##elif offset_left.is_colliding():
					##article.position.x = offset_left.get_collider().position.x + (offset_left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
		#if (offset_left.is_colliding() && (offset_left.get_collider() is TerrainArea2D && offset_left.get_collider().type == "Wall")):
				##print("terrain type: " + str(left.get_collider().type))
				#if offset_left.target_position.x >= 0.0:
					#if article.entity.body_vel.x < 0.0:
						#article.entity.body_vel.x = 0.0
					#print("true")
					#article.position.x = offset_left.get_collider().position.x + (offset_left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
		#if (top.is_colliding() && top.get_collider() is TerrainArea2D):
			#if article.entity.body_vel.y < 0:
				#article.entity.body_vel.y = 0.0
				#article.position.y = top.get_collider().position.y + (top.get_collider().collision_shape.size.y*0.5) + height
		#elif (offset_top.is_colliding() && offset_top.get_collider() is TerrainArea2D):
			#if article.entity.body_vel.y < 0:
				#article.entity.body_vel.y = 0.0
				#article.position.y = offset_top.get_collider().position.y + (offset_top.get_collider().collision_shape.size.y*0.5) + height
#
		#bottom.enabled = article.entity.body_vel.y >= 0
		##offset_bottom.enabled = article.entity.body_vel.y >= 0
		##if (bottom.is_colliding()):
		##if (bottom.is_colliding() || offset_bottom.is_colliding()):
		##if ((bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew))
			##|| (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D))
		##):
			##var coll_point: Vector2 = bottom.get_collision_point()
			###print("collision point: " + str(coll_point))
			##if (bottom.is_colliding() && bottom.get_collider() is TerrainArea2D):
			###if (bottom.get_collider() is TerrainArea2D && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				##article.entity.body_on_ground = true
				##print("on ground!")
				##article.entity.body_vel.y = 0.0
				###if offset_bottom.target_position.y < 0.0:
				##article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			##elif (bottom.is_colliding() && bottom.get_collider() is PlatformNew && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				##article.entity.body_on_ground = true
				##article.entity.is_on_platform = true
				##print("on platform!")
				##article.entity.body_vel.y = 0.0
				###if offset_bottom.target_position.y <= 0.0:
				##article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			###elif offset_bottom.is_colliding() && offset_bottom.get_collider() is TerrainArea2D:
				###article.entity.body_on_ground = true
				####if article.entity.body_vel.y < 0.0:
				###if offset_bottom.target_position.y <= 0.0:
					###article.entity.body_vel.y = 0.0
					###article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
			##elif offset_bottom.is_colliding() && offset_bottom.get_collider() is PlatformNew:
				##article.entity.body_on_ground = true
				##article.entity.is_on_platform = true
				###print("on platform!")
				##if offset_bottom.target_position.y <= 0.0:
					##article.entity.body_vel.y = 0.0
					##article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		##else:
			##article.entity.body_on_ground = false
			##article.entity.is_on_platform = false
			#
			#
		#var coll_point: Vector2 = bottom.get_collision_point()
		#if ( bottom.is_colliding() &&
			#( (bottom.get_collider() is TerrainArea2D && bottom.get_collider().type == "Floor") ||
				#(  bottom.get_collider() is PlatformNew &&
					#coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD
				#)
			#)
		#):
			#if article.entity.body_vel.y >= 0:
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = bottom.get_collider() is PlatformNew
				#article.entity.body_vel.y = 0.0
			#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		#elif (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || (offset_bottom.get_collider() is TerrainArea2D && offset_bottom.get_collider().type == "Floor"))):
				#if article.entity.body_vel.y >= 0:
					#article.entity.body_on_ground = true
					##article.entity.is_on_platform = true
					#article.entity.is_on_platform = offset_bottom.get_collider() is PlatformNew
					#article.entity.body_vel.y = 0.0
				#if offset_bottom.target_position.y <= 0.0:
					#article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		#else:
			#article.entity.body_on_ground = false
			#article.entity.is_on_platform = false
			#
			#
			#
		##article.entity.body_on_ground = bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew)
		##article.entity.is_on_platform = bottom.is_colliding() && bottom.get_collider() is PlatformNew
		##if bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew):
			##var coll_point: Vector2 = bottom.get_collision_point()
			###article.entity.body_vel.y = 0.0
			###article.entity.body_on_ground = true
			###article.entity.is_on_platform = bottom.get_collider() is PlatformNew
			###if bottom.get_collider() is TerrainArea2D:
			###elif bottom.get_collider() is PlatformNew && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD:
				###article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			##if bottom.get_collider() is TerrainArea2D:
				##print("on ground!")
				##article.entity.body_vel.y = 0.0
				##article.entity.body_on_ground = true
				##article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			###elif bottom.get_collider() is PlatformNew:
			##elif bottom.get_collider() is PlatformNew && (coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				##print("on platform!")
				##article.entity.body_vel.y = 0.0
				##article.entity.body_on_ground = true
				##article.entity.is_on_platform = true
				###if coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD:
				##article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		##elif offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D):
			###if offset_bottom.get_collider() is TerrainArea2D:
				###print("on ground!")
				###if offset_bottom.target_position.y <= 0.0:
					###article.entity.body_vel.y = 0.0
					###article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
			##if offset_bottom.get_collider() is PlatformNew:
				##print("on platform!")
				##article.entity.body_on_ground = true
				##article.entity.is_on_platform = true
				##if offset_bottom.target_position.y <= 0.0:
					##article.entity.body_vel.y = 0.0
					##article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		##else:
			##article.entity.body_on_ground = false
			##article.entity.is_on_platform = false
				#
		#last_global_position = global_position
	#).call_deferred()
	
func _on_area_entered(area: Area2D) -> void:
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
			
#func handle_ground_collision(article: Article) -> void:
	#var coll_point: Vector2 = bottom.get_collision_point()
	#if (!bottom.is_colliding() && !offset_bottom.is_colliding()):
		#article.entity.body_on_ground = false
		#article.entity.is_on_platform = false
		#return
	#if ( bottom.get_collider() is TerrainArea2D ||
		#(  bottom.get_collider() is PlatformNew &&
			#coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD
		#)
	#):
		#if article.entity.body_vel.y >= 0:
			#article.entity.body_on_ground = true
			#article.entity.is_on_platform = bottom.get_collider() is PlatformNew
			##article.entity.body_vel.y = 0.0
		#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		#return
	#if (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D)):
		#if article.entity.body_vel.y >= 0:
			#article.entity.body_on_ground = true
			#article.entity.is_on_platform = true
		#if offset_bottom.target_position.y <= 0.0:
			##article.entity.body_vel.y = 0.0
			#article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
	#pass
	
func update_ecb_rays(article: Article, delta: float):
		bottom.force_raycast_update()
		top.force_raycast_update()
		left.force_raycast_update()
		right.force_raycast_update()
		
		var velocity_vec: Vector2 = global_position - last_global_position
		offset_bottom.target_position = offset_bottom.to_local(global_position - velocity_vec)
		offset_top.target_position = offset_top.to_local(global_position - velocity_vec) + offset_top.position
		offset_left.target_position = offset_left.to_local(global_position - velocity_vec) + offset_left.position
		offset_right.target_position = offset_right.to_local(global_position - velocity_vec) + offset_right.position
		
		offset_bottom.force_raycast_update()
		offset_top.force_raycast_update()
		offset_left.force_raycast_update()
		offset_right.force_raycast_update()
		
		#bottom_detector.force_raycast_update()
		#var vel_detection_vec: Vector2 = global_position - (article.entity.body_vel * delta)
		#bottom_detector.target_position = bottom_detector.to_local(global_position - vel_detection_vec)
		bottom_detector.target_position = bottom_detector.to_local(global_position + article.entity.body_vel * delta)
		top_detector.target_position = top_detector.to_local(global_position + article.entity.body_vel * delta) + offset_top.position
		left_detector.target_position = left_detector.to_local(global_position + article.entity.body_vel * delta) + offset_left.position
		right_detector.target_position = right_detector.to_local(global_position + article.entity.body_vel * delta) + offset_right.position
		
		bottom_detector.force_raycast_update()
		top_detector.force_raycast_update()
		left_detector.force_raycast_update()
		right_detector.force_raycast_update()
		
		if left_detected && left_detector.is_colliding():
			article.position.x = left_detector.get_collider().position.x + (left_detector.get_collider().collision_shape.size.x*0.5) + (width*0.5)
			if article.entity.body_vel.x < 0.0:
				article.entity.body_vel.x = 0.0
		if right_detected && right_detector.is_colliding():
			article.position.x = right_detector.get_collider().position.x - (right_detector.get_collider().collision_shape.size.x*0.5) - (width*0.5)
			if article.entity.body_vel.x > 0.0:
				article.entity.body_vel.x = 0.0
		if top_detected && top_detector.is_colliding():
			article.position.y = top_detector.get_collider().position.y + (top_detector.get_collider().collision_shape.size.y*0.5) + height
			if article.entity.body_vel.y < 0.0:
				article.entity.body_vel.y = 0.0
		
		if (right.is_colliding() && (right.get_collider() is TerrainArea2D && right.get_collider().type == "Wall")):
				if article.entity.body_vel.x > 0.0:
					article.entity.body_vel.x = 0.0
				article.position.x = right.get_collider().position.x - (right.get_collider().collision_shape.size.x*0.5) - (width*0.5)
		if (offset_right.is_colliding() && (offset_right.get_collider() is TerrainArea2D && offset_right.get_collider().type == "Wall")):
				if offset_right.target_position.x <= 0.0:
					if article.entity.body_vel.x > 0.0:
						article.entity.body_vel.x = 0.0
					article.position.x = offset_right.get_collider().position.x - (offset_right.get_collider().collision_shape.size.x*0.5) - (width*0.5)
		if (right_detector.is_colliding() && (right_detector.get_collider() is TerrainArea2D && right_detector.get_collider().type == "Wall")):
			if article.entity.body_vel.x > 0.0:
				right_detected = true
		else:
			right_detected = false
				
		if (left.is_colliding() && (left.get_collider() is TerrainArea2D && left.get_collider().type == "Wall")):
				if article.entity.body_vel.x < 0.0:
					article.entity.body_vel.x = 0.0
				article.position.x = left.get_collider().position.x + (left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
		if (offset_left.is_colliding() && (offset_left.get_collider() is TerrainArea2D && offset_left.get_collider().type == "Wall")):
				if offset_left.target_position.x >= 0.0:
					if article.entity.body_vel.x < 0.0:
						article.entity.body_vel.x = 0.0
					article.position.x = offset_left.get_collider().position.x + (offset_left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
		if (left_detector.is_colliding() && (left_detector.get_collider() is TerrainArea2D && left_detector.get_collider().type == "Wall")):
				if article.entity.body_vel.x < 0.0:
					left_detected = true
		else:
			left_detected = false
			
		if (top.is_colliding() && top.get_collider() is TerrainArea2D):
			if article.entity.body_vel.y < 0:
				article.entity.body_vel.y = 0.0
				article.position.y = top.get_collider().position.y + (top.get_collider().collision_shape.size.y*0.5) + height
		if (offset_top.is_colliding() && offset_top.get_collider() is TerrainArea2D):
			if article.entity.body_vel.y < 0:
				article.entity.body_vel.y = 0.0
				article.position.y = offset_top.get_collider().position.y + (offset_top.get_collider().collision_shape.size.y*0.5) + height
		if (top_detector.is_colliding() && (top_detector.get_collider() is TerrainArea2D && top_detector.get_collider().type == "Floor")):
			if article.entity.body_vel.y <= 0.0:
					top_detected = true
		else:
			top_detected = false

		bottom.enabled = article.entity.body_vel.y >= 0
		#offset_bottom.enabled = article.entity.body_vel.y >= 0
		#if (bottom.is_colliding()):
		#if (bottom.is_colliding() || offset_bottom.is_colliding()):
		#if ((bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew))
			#|| (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D))
		#):
			#var coll_point: Vector2 = bottom.get_collision_point()
			##print("collision point: " + str(coll_point))
			#if (bottom.is_colliding() && bottom.get_collider() is TerrainArea2D):
			##if (bottom.get_collider() is TerrainArea2D && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				#article.entity.body_on_ground = true
				#print("on ground!")
				#article.entity.body_vel.y = 0.0
				##if offset_bottom.target_position.y < 0.0:
				#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			#elif (bottom.is_colliding() && bottom.get_collider() is PlatformNew && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = true
				#print("on platform!")
				#article.entity.body_vel.y = 0.0
				##if offset_bottom.target_position.y <= 0.0:
				#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			##elif offset_bottom.is_colliding() && offset_bottom.get_collider() is TerrainArea2D:
				##article.entity.body_on_ground = true
				###if article.entity.body_vel.y < 0.0:
				##if offset_bottom.target_position.y <= 0.0:
					##article.entity.body_vel.y = 0.0
					##article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
			#elif offset_bottom.is_colliding() && offset_bottom.get_collider() is PlatformNew:
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = true
				##print("on platform!")
				#if offset_bottom.target_position.y <= 0.0:
					#article.entity.body_vel.y = 0.0
					#article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		#else:
			#article.entity.body_on_ground = false
			#article.entity.is_on_platform = false
			
		if bottom_detected && bottom_detector.is_colliding():
			article.position.y = bottom_detector.get_collider().position.y - (bottom_detector.get_collider().collision_shape.size.y*0.5)
			article.entity.body_vel.y = 0.0
		var coll_point: Vector2 = bottom.get_collision_point()
		if ( bottom.is_colliding() &&
			( (bottom.get_collider() is TerrainArea2D && bottom.get_collider().type == "Floor") ||
				(  bottom.get_collider() is PlatformNew &&
					coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD
				)
			)
		):
			if article.entity.body_vel.y >= 0.0:
				article.entity.body_on_ground = true
				article.entity.is_on_platform = bottom.get_collider() is PlatformNew
				article.entity.body_vel.y = 0.0
			article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		elif (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || (offset_bottom.get_collider() is TerrainArea2D && offset_bottom.get_collider().type == "Floor"))):
				if article.entity.body_vel.y >= 0.0:
					article.entity.body_on_ground = true
					#article.entity.is_on_platform = true
					article.entity.is_on_platform = offset_bottom.get_collider() is PlatformNew
					article.entity.body_vel.y = 0.0
				if offset_bottom.target_position.y <= 0.0:
					article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		elif (bottom_detector.is_colliding() && (bottom_detector.get_collider() is PlatformNew || (bottom_detector.get_collider() is TerrainArea2D && bottom_detector.get_collider().type == "Floor"))):
				if article.entity.body_vel.y >= 0.0:
					bottom_detected = true
		else:
			article.entity.body_on_ground = false
			article.entity.is_on_platform = false
			bottom_detected = false
			
			
			
		#article.entity.body_on_ground = bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew)
		#article.entity.is_on_platform = bottom.is_colliding() && bottom.get_collider() is PlatformNew
		#if bottom.is_colliding() && (bottom.get_collider() is TerrainArea2D || bottom.get_collider() is PlatformNew):
			#var coll_point: Vector2 = bottom.get_collision_point()
			##article.entity.body_vel.y = 0.0
			##article.entity.body_on_ground = true
			##article.entity.is_on_platform = bottom.get_collider() is PlatformNew
			##if bottom.get_collider() is TerrainArea2D:
			##elif bottom.get_collider() is PlatformNew && coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD:
				##article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			#if bottom.get_collider() is TerrainArea2D:
				#print("on ground!")
				#article.entity.body_vel.y = 0.0
				#article.entity.body_on_ground = true
				#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
			##elif bottom.get_collider() is PlatformNew:
			#elif bottom.get_collider() is PlatformNew && (coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD):
				#print("on platform!")
				#article.entity.body_vel.y = 0.0
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = true
				##if coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD:
				#article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		#elif offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D):
			##if offset_bottom.get_collider() is TerrainArea2D:
				##print("on ground!")
				##if offset_bottom.target_position.y <= 0.0:
					##article.entity.body_vel.y = 0.0
					##article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
			#if offset_bottom.get_collider() is PlatformNew:
				#print("on platform!")
				#article.entity.body_on_ground = true
				#article.entity.is_on_platform = true
				#if offset_bottom.target_position.y <= 0.0:
					#article.entity.body_vel.y = 0.0
					#article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		#else:
			#article.entity.body_on_ground = false
			#article.entity.is_on_platform = false
				
		last_global_position = global_position
	
