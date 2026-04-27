class_name HitboxManager extends Node2D

signal hit_something(hitbox: Node2D, hurtbox: Node2D)

var hitboxes: Array[Hitbox]

func _ready() -> void:
	init_hitboxes()
			
func _hitbox_hit_something(hitbox: Node2D, hurtbox: Node2D):
	#print("Hitbox that hit something: " + str(hitbox.name) + ", what it hit: " + str(hurtbox.name))
	hit_something.emit(hitbox, hurtbox)
	
func init_hitboxes() -> void:
	for child in get_children():
		if child is Hitbox:
			child.hit_something.connect(_hitbox_hit_something)
			hitboxes.append(child)
		elif child is not Hitbox and child.get_child_count() > 0:
			for grandchild in child.get_children():
				if grandchild is Hitbox:
					grandchild.hit_something.connect(_hitbox_hit_something)
					hitboxes.append(grandchild)
