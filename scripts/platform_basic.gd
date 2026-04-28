extends StaticBody2D
class_name PlatformBasic

@onready var area: Area2D = $Area2D

signal _article_colliding_with_platform(
	platform: StaticBody2D,
	article: Node2D
)

func _ready():
	pass
	
func _physics_process(_delta):
	if area.has_overlapping_areas():
		var overlapping_areas = area.get_overlapping_areas()
		#print(overlapping_areas)
		for a in overlapping_areas:
			#if a && a.name == "Hurtbox":
			if a && a is Hurtbox:
				#_article_colliding_with_platform.emit(self, a)
				_article_colliding_with_platform.emit(self, a.get_parent())
