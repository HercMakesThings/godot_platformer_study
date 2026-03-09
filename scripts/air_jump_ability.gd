class_name AirJump extends Ability

#@onready var body: PlayerNew = $"../.."
@export var body: CharacterBody2D
@export var input: Node

@export var air_jump_count: int = 1
@export var air_jump_modifier: float = 0.75
var air_jumps: int

func _ready() -> void:
	air_jumps = air_jump_count

#func tick_ability(input: InputGameComponent, movement: MovementComponent, _delta: float) -> void:
func tick_ability(movement: MovementComponent, _delta: float) -> void:
	if (air_jumps > 0 &&
		input.btn_3_input &&
		movement.current_state == movement.MoveState.AIRBORNE &&
		!body.is_on_floor() &&
		movement.can_move):
		body.velocity.y = movement.JUMP_VELOCITY * air_jump_modifier
		air_jumps -= 1
		
	if air_jumps < air_jump_count && body.is_on_floor():
		air_jumps = air_jump_count
		
