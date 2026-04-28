extends Node
class_name PlatformManager

var platforms: Dictionary[String, PlatformBasic] = {}
#var platforms := Array()

#signal _article_on_platform(platform: PlatformBasic, collider: Area2D)

func _ready():
	for child in get_children():
		if child is PlatformBasic:
			platforms[child.name.to_lower()] = child
			child._article_colliding_with_platform.connect(_on_platform_colliding)
			#print(child.name)
	
#func _on_platform_colliding(plat: PlatformBasic, area: Area2D):
	#var overlapping_areas = area.get_overlapping_areas()
	##var overlapping_areas = platforms[platform].get_child("Area2D").get_overlapping_areas()
	#for a in overlapping_areas:
		#if a.get_parent() is PlatformBasic:
			##print(area.get_parent().name)
			#print("currently on platform: " + str(area.name))
			#_pl_on_platform.emit(a.get_parent(), area.get_parent())
func _on_platform_colliding(_plat: PlatformBasic, article: Node2D):
	print("currently on platform: " + str(article.name))
	#_article_on_platform.emit(plat, article)
	article.entity.is_on_platform = true
			
