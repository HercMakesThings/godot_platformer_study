class_name PlayerNew extends CharacterBody2D

@onready var input_game_component: InputGameComponent = %InputGameComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var health_manager: HealthManager = %HealthManager
@onready var stamina_manager: StaminaManager = %StaminaManager


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# capture player input
	input_game_component.update()
	movement_component.direction = input_game_component.dir_input
	movement_component.will_jump = input_game_component.btn_3_input
	movement_component.deadzone = input_game_component.deadzone_ls
	movement_component.hard_press_thresh = input_game_component.hardpress_thresh_ls
	
	movement_component.tick(delta)
	
	move_and_slide()
