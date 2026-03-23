extends StaticBody2D
class_name PlatformBasic
#@onready var player = $"../Player"
#@onready var player: Player = $"../../Player"


#@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var area: Area2D = $Area2D

signal _pl_colliding_with_platform

func _ready():
	pass
	
func _physics_process(_delta):
	if area.has_overlapping_areas():
	#if collision_shape.has_overlapping_areas():
		var overlapping_areas = area.get_overlapping_areas()
		#var overlapping_areas = collision_shape.get_overlapping_areas()
		#print(overlapping_areas)
		for a in overlapping_areas:
			#print(a.name)
			if a && a.name == "Hurtbox":
				_pl_colliding_with_platform.emit(true, a)
	#print("player direction from platform: %s" % str(player.player_orientation))
	#print(str(player.find_child("FloorContactRay").is_colliding()))
	#var player_colliding = player.find_child("FloorContactRay").is_colliding()
	#if (player_colliding):
		#var collider = player.find_child("FloorContactRay").get_collider()
		##print(collider.get_class())
		#if (player.find_child("FSM").current_state.name.to_lower() == "playercrouch"):
			##if collider is PlatformBasic && area.overlaps_body(collider):
			#if collider is PlatformBasic:
				#player.find_child("CollisionShape2D", false).disabled = true
				##collision_shape.disabled = true
				##_pl_colliding_with_platform.emit(true)
			#else:
				#player.find_child("CollisionShape2D", false).disabled = false
				##collision_shape.disabled = false
				##_pl_colliding_with_platform.emit(false)
			##player.find_child("Hurtbox").find_child("CollisionShape2D").disabled = true
		#else:
			#player.find_child("CollisionShape2D", false).disabled = false
			#collision_shape.disabled = false
			#_pl_colliding_with_platform.emit(false)
			#player.find_child("Hurtbox").find_child("CollisionShape2D").disabled = false
	#print(str(self.collision_layer))
	pass
