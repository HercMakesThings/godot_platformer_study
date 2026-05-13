class_name HitboxManager extends Node2D

signal hit_something(hitbox: Node2D, hurtbox: Node2D)
#signal hitbox_shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D)

var hitboxes: Array[Hitbox]

func _ready() -> void:
	init_hitboxes()
			
func _hitbox_hit_something(hitbox: Node2D, hurtbox: Node2D) -> void:
	#print("Hitbox that hit something: " + str(hitbox.name) + ", what it hit: " + str(hurtbox.name))
	hit_something.emit(hitbox, hurtbox)
	
func _hitbox_shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D) -> void:
	print(str(hitbox.name) + " hitbox hit " + str(hurtbox.name) + " at shape index " + str(shape_index))
	#hitbox_shape_hit_something.emit(hitbox, shape_index, hurtbox)
	
func init_hitboxes() -> void:
	for child in get_children():
		if child is Hitbox:
			child.hit_something.connect(_hitbox_hit_something)
			child.shape_hit_something.connect(_hitbox_shape_hit_something)
			hitboxes.append(child)
		elif child is not Hitbox and child.get_child_count() > 0:
			for grandchild in child.get_children():
				if grandchild is Hitbox:
					grandchild.hit_something.connect(_hitbox_hit_something)
					grandchild.hit_something.connect(_hitbox_shape_hit_something)
					hitboxes.append(grandchild)
