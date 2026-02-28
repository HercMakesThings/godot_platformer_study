extends Node
class_name PlatformManager

var platforms: Dictionary[String, PlatformBasic] = {}
#var platforms := Array()

signal _pl_on_platform(platform: PlatformBasic, collider: Area2D)

func _ready():
	for child in get_children():
		if child is PlatformBasic:
			platforms[child.name.to_lower()] = child
			child._pl_colliding_with_platform.connect(_on_platform_colliding)
			#print(child.name)
	
func _on_platform_colliding(is_colliding: bool, area: Area2D):
	#if is_colliding && area.name == "Hurtbox":
	if is_colliding:
		#print("area... " + area.name)
		#print("colliding with player signal read from PlatformManager!")
		#print(area.get_parent().get_property_list())
		#print(area.get_parent().name)
		#print(platforms)
		#for p in platforms:
			#print(platforms[p].get_parent().name)
		for platform in platforms:
			#print(platforms[platform])
			var overlapping_areas = area.get_overlapping_areas()
			#var overlapping_areas = platforms[platform].get_child("Area2D").get_overlapping_areas()
			for a in overlapping_areas:
				#print("name!" + a.get_parent().name)
				#print(a)
				#if a.name == area.name:
				if a.get_parent() is PlatformBasic:
					#print(area.get_parent().name)
					_pl_on_platform.emit(a.get_parent(), area.get_parent())
				#print("platform name: " + platform + ", collider name: " + area.get_parent().name)
					#print("platform name: " + a.get_parent().name + ", collider name: " + area.get_parent().name)
		pass
