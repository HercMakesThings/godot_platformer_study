class_name OrientationVisualizer extends RayCast2D

@export var body: CharacterBody2D

func _physics_process(_delta: float):
	if body == null:
		return
	if body.movement_component.orientation == -1:
		target_position.x = -absf(target_position.x)
	elif body.movement_component.orientation == 1:
		target_position.x = absf(target_position.x)
