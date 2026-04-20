class_name HitboxManager extends Node2D

signal hit_something(hitbox: Node2D, hurtbox: Node2D)

func _ready() -> void:
	for child in get_children():
		if child is HitboxNew:
			child.hit_something.connect(_hitbox_hit_something)
		elif child is not HitboxNew and child.get_child_count() > 0:
			for grandchild in child.get_children():
				if grandchild is HitboxNew:
					grandchild.hit_something.connect(_hitbox_hit_something)
			
func _hitbox_hit_something(hitbox: Node2D, hurtbox: Node2D):
	#print("Hitbox that hit something: " + str(hitbox.name) + ", what it hit: " + str(hurtbox.name))
	hit_something.emit(hitbox, hurtbox)
