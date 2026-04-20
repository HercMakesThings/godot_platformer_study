extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent

func _ready() -> void:
	add_to_group("items", true)
	movement_component.STARTING_VELOCITY = Vector2(-movement_component.MAX_AIR_SPEED, -100)
	
func _physics_process(delta: float) -> void:
	velocity = movement_component.compute_vel(delta, Vector2.ZERO)
	move_and_slide()
