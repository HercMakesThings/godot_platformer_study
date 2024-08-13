extends Area2D
class_name HitboxBase

@export_range(1,20,1) var dmg: float = 15
@export var kb_angle: Vector2 = Vector2(1,2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	print("ping!")
	pass # Replace with function body.
