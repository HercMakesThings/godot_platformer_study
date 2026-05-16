class_name EnvironmentCollisionBody extends Area2D

@onready var top: RayCast2D = %top
@onready var right: RayCast2D = %right
@onready var bottom: RayCast2D = %bottom
@onready var left: RayCast2D = %left

@onready var offset_bottom: RayCast2D = %offset_bottom

@onready var shape: CollisionShape2D = %shape

@export var height: float = 24.0
@export var center: float = 16.0
@export var width: float = 20.0

@export var COLLISION_POINT_THRESHOLD: float = 4.0

var last_global_position: Vector2

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
	shape.shape.points = PackedVector2Array([
		Vector2(0, -height),
		Vector2(width*0.5, -center),
		Vector2.ZERO,
		Vector2(-width*0.5, -center)
	])
	area_entered.connect(_on_area_entered)
	#offset_bottom.target_position = Vector2(0.0, 40.0)
	offset_bottom.target_position = Vector2(0.0, 0.0)
	last_global_position = global_position

func tick(article: Article) -> void:
	(func():
		bottom.force_raycast_update()
		top.force_raycast_update()
		left.force_raycast_update()
		right.force_raycast_update()
		
		var velocity_vec: Vector2 = global_position - last_global_position
		offset_bottom.target_position = offset_bottom.to_local(global_position - velocity_vec)
		offset_bottom.force_raycast_update()
		
		if (right.is_colliding() && right.get_collider() is TerrainArea2D):
				article.entity.body_vel.x = 0.0
				article.position.x = right.get_collider().position.x - (right.get_collider().collision_shape.size.x*0.5) - (width*0.5)
		if (left.is_colliding() && left.get_collider() is TerrainArea2D):
				article.entity.body_vel.x = 0.0
				article.position.x = left.get_collider().position.x + (left.get_collider().collision_shape.size.x*0.5) + (width*0.5)
		if (top.is_colliding() && top.get_collider() is TerrainArea2D):
			if article.entity.body_vel.y < 0:
				article.entity.body_vel.y = 0.0
				article.position.y = top.get_collider().position.y + (top.get_collider().collision_shape.size.y*0.5) + height

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
			
			
		var coll_point: Vector2 = bottom.get_collision_point()
		if ( bottom.is_colliding() &&
			( bottom.get_collider() is TerrainArea2D ||
				(  bottom.get_collider() is PlatformNew &&
					coll_point.distance_to(bottom.global_position + bottom.target_position) <= COLLISION_POINT_THRESHOLD
				)
			)
		):
			if article.entity.body_vel.y >= 0:
				article.entity.body_on_ground = true
				article.entity.is_on_platform = bottom.get_collider() is PlatformNew
			#article.entity.body_vel.y = 0.0
			article.position.y = bottom.get_collider().position.y - (bottom.get_collider().collision_shape.size.y*0.5)
		elif (offset_bottom.is_colliding() && (offset_bottom.get_collider() is PlatformNew || offset_bottom.get_collider() is TerrainArea2D)):
				if article.entity.body_vel.y >= 0:
					article.entity.body_on_ground = true
					article.entity.is_on_platform = true
				if offset_bottom.target_position.y <= 0.0:
					#article.entity.body_vel.y = 0.0
					article.position.y = offset_bottom.get_collider().position.y - (offset_bottom.get_collider().collision_shape.size.y*0.5)
		else:
			article.entity.body_on_ground = false
			article.entity.is_on_platform = false
			
			
			
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
	).call_deferred()
	
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
	
