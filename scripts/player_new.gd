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
	movement_component.deadzone = input_game_component.deadzone_ls
	movement_component.hard_press_thresh = input_game_component.hardpress_thresh_ls
	
func _physics_process(delta: float) -> void:
	# capture player input
	input_game_component.update()
	movement_component.direction = input_game_component.dir_input
	#movement_component.will_jump = input_game_component.btn_3_input
	movement_component.jump_pressed = input_game_component.btn_3_input
	movement_component.jump_just_pressed = input_game_component.btn_3_just_pressed
	movement_component.jump_released = input_game_component.btn_3_input_released
	#movement_component.deadzone = input_game_component.deadzone_ls
	#movement_component.hard_press_thresh = input_game_component.hardpress_thresh_ls
	
	movement_component.tick(delta)
	
	#ability_manager.update_abilities(input_game_component, movement_component, delta)
	ability_manager.update_abilities(movement_component, delta)
	
	## debug
	#debug_prints()
	
	move_and_slide()
	
func _on_platform(_platform: PlatformBasic, collider: CharacterBody2D) -> void:
	#print("on a platform!!")
	#print("collider: " + str(collider.name))
	if collider.name == "PlayerNew":
		movement_component.is_on_platform = true
		
func debug_prints():
	print(str(name) + " -> current move state: " + str(movement_component.MoveState.keys()[movement_component.current_state]))
	#print(str(name) + " -> direction.x: " + str(movement_component.direction.x))
	#print(str(name) + " -> direction.y: " + str(movement_component.direction.y))
	#print(str(name) + " -> orientation: " + str(movement_component.orientation))
	#print(str(name) + " -> full crouch threshold: " + str(-deadzone + -crouch_thresh))
	#print(str(name) + " -> accel: " + str(accel))
	#print(str(name) + " -> current velocity: " + str(velocity))
	#print(str(name) + " -> current x input: " + str(movement_component.direction.x))
	#print(str(name) + " -> dot product: " + str(movement_component.direction.dot(body.velocity.normalized())))
	#print(str(name) + " -> deadzone: " + str(movement_component.deadzone))
	#print(str(name) + " -> velocity length: " + str(velocity.length()))
	#print(str(name) + " -> frame #: " + str(movement_component.frame))
