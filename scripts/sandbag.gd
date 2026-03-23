class_name Sandbag extends CharacterBody2D

@onready var movement_component: MovementComponent = %MovementComponent
@onready var health_manager: HealthManager = %HealthManager
@onready var ability_manager: AbilityManager = %AbilityManager
@onready var platform_manager: PlatformManager = $"../PlatformManager"

func _ready() -> void:
	platform_manager._pl_on_platform.connect(_on_platform)

func _physics_process(delta: float) -> void:
	movement_component.tick(delta)
	
	#ability_manager.update_abilities(input_game_component, movement_component, delta)
	ability_manager.update_abilities(movement_component, delta)
	
	move_and_slide()
	
func _on_platform(_platform: PlatformBasic, collider: CharacterBody2D) -> void:
	if collider.name == "Sandbag":
		movement_component.is_on_platform = true
