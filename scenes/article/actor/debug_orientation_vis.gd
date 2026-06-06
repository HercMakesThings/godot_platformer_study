class_name DebugOrientationVisualizer extends RayCast2D

@export var body: Article

func _physics_process(_delta: float):
	visible = body.debug
	if body == null:
		return
	if !body.debug:
		return
	if body.entity.orientation == -1:
		target_position.x = -absf(target_position.x)
	elif body.entity.orientation == 1:
		target_position.x = absf(target_position.x)
