class_name Airdodge extends Ability

@onready var body: PlayerNew = $"../.."

@export var air_dodge_count: int = 1
@export var air_dodge_length: int = 30
var air_dodge: int

func _ready() -> void:
	air_dodge = air_dodge_count

func tick_ability(input: InputGameComponent, movement: MovementComponent) -> void:
	pass
