class_name AnimationComponent extends Node

@export var body: PhysicsBody2D
@export var model: Node
@export var hurtbox: Hurtbox
#@export var movement_manager: MovementManager

func _physics_process(_delta: float) -> void:
	if body.entity.current_state == body.entity.MoveState.CROUCH:
		hurtbox.find_child("CollisionShape2D").scale.y = 0.5
		hurtbox.find_child("CollisionShape2D").position.y = 8.15
		if model is ColorRect:
			model.size.y = 15
	else:
		if model is ColorRect && model.size.y < 30:
			model.size.y = 30
		hurtbox.find_child("CollisionShape2D").scale.y = 1
		hurtbox.find_child("CollisionShape2D").position.y = 0
