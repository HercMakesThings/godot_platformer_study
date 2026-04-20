class_name OrientationVisualizer extends RayCast2D

@export var body: CharacterBody2D

func _physics_process(_delta: float):
	if body == null:
		return
	#if body.movement_manager.orientation == -1:
		#target_position.x = -absf(target_position.x)
	#elif body.movement_manager.orientation == 1:
		#target_position.x = absf(target_position.x)
	#if body.movement.orientation == -1:
		#target_position.x = -absf(target_position.x)
	#elif body.movement.orientation == 1:
		#target_position.x = absf(target_position.x)
	if body.entity.orientation == -1:
		target_position.x = -absf(target_position.x)
	elif body.entity.orientation == 1:
		target_position.x = absf(target_position.x)
