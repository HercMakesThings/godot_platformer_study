class_name PlayerNew extends CharacterBody2D

@onready var input_game_component: InputGameComponent = %InputGameComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var health_manager: HealthManager = %HealthManager
@onready var stamina_manager: StaminaManager = %StaminaManager
@onready var ability_manager: AbilityManager = %AbilityManager

#@onready var platform_manager: PlatformManager = %PlatformManager
@onready var platform_manager: PlatformManager = $"../PlatformManager"


func _ready() -> void:
	platform_manager._pl_on_platform.connect(_on_platform)
	
func _physics_process(delta: float) -> void:
	# capture player input
	input_game_component.update()
	movement_component.direction = input_game_component.dir_input
	movement_component.will_jump = input_game_component.btn_3_input
	movement_component.deadzone = input_game_component.deadzone_ls
	movement_component.hard_press_thresh = input_game_component.hardpress_thresh_ls
	
	movement_component.tick(delta)
	
	ability_manager.update_abilities(input_game_component, movement_component, delta)
	
	move_and_slide()
	
func _on_platform(_platform: PlatformBasic, _collider: CharacterBody2D) -> void:
	#print("on a platform!!")
	movement_component.is_on_platform = true
