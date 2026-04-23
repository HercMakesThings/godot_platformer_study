class_name PlayerNew extends CharacterBody2D

#@onready var input_game_component: InputGameComponent = %InputGameComponent
@onready var movement_manager: MovementManager = %MovementManager
@onready var health_manager: HealthManager = %HealthManager
@onready var stamina_manager: StaminaManager = %StaminaManager
@onready var ability_manager: AbilityManager = %AbilityManager

#@onready var platform_manager: PlatformManager = %PlatformManager
@onready var platform_manager: PlatformManager = $"../PlatformManager"

#@onready var hitboxes: Node2D = %Hitboxes
@onready var hitbox_manager: HitboxManager = %HitboxManager

#@export var movement: MovementRes
#@export var contact_point: RayCast2D

@export var input_game_component: InputGameComponent

@export var ecd: EnvironmentCollisionDiamond
@export var hurtbox: Hurtbox
@export var shield: Area2D
@onready var floor_contact_ray: RayCast2D = %FloorContactRay

@export var entity: Entity
@export var entity_movement: EntityMoveRes

#@export var placeholder_model: ColorRect
@export var model: Node

@export var abilities: Dictionary[String, AbilityRes]

#@export var ad_flash_timer: Timer
#@onready var timers: Node = %Timers
@export var TIMERS: Node
var timers: Dictionary[String, Timer]


func _ready() -> void:
	platform_manager._pl_on_platform.connect(_on_platform)
	hitbox_manager.hit_something.connect(_on_hit_something)
	#movement_manager.deadzone = input_game_component.deadzone_ls
	#movement_manager.hard_press_thresh = input_game_component.hardpress_thresh_ls
	#movement.init()
	entity.init()
	for timer in TIMERS.get_children():
		timers[timer.name] = timer
	for i in abilities:
		#abilities[abilities[i].resource_name] = abilities[i]
		abilities[i]._init_ability(self)
		print(str(name) + " Ability Resource: " + str(abilities[i].name))
		#abilities.erase(abilities[i])
		#abilities[abilities[i].resource_name]._init_ability()
	
func _physics_process(delta: float) -> void:
	# capture player input
	input_game_component.update()
	
	###########################################
	#### movement manager method ##############
	###########################################
	#movement_manager.direction = input_game_component.dir_input
	#movement_manager.jump_pressed = input_game_component.btn_3_input
	#movement_manager.jump_just_pressed = input_game_component.btn_3_just_pressed
	#movement_manager.jump_released = input_game_component.btn_3_input_released
	
	#movement_manager.deadzone = input_game_component.deadzone_ls
	#movement_manager.hard_press_thresh = input_game_component.hardpress_thresh_ls
	
	#movement_manager.tick(delta)
	#ability_manager.update_abilities(input_game_component, movement_manager, delta)
	#ability_manager.update_abilities(movement_manager, delta)
	
	###########################################
	#### movement component resource (fat) ####
	###########################################
	
	#movement.jump_pressed = input_game_component.btn_3_input
	#movement.jump_just_pressed = input_game_component.btn_3_just_pressed
	#movement.jump_released = input_game_component.btn_3_input_released
	#movement.compute_movement(
		#delta,
		#input_game_component.dir_input,
		#is_on_floor(),
		#contact_point.is_colliding()
	#)
	#
	#ability_manager.update_abilities(movement, delta)
	#
	#velocity = movement.body_vel
	
	###########################################
	### movement component resource (thin) ####
	###########################################
	entity.jump_pressed = input_game_component.btn_3_input
	entity.jump_just_pressed = input_game_component.btn_3_just_pressed
	entity.jump_released = input_game_component.btn_3_input_released
	entity.direction = input_game_component.dir_input
	
	#entity.contact_point = contact_point.is_colliding()
	entity.body_on_ground = is_on_floor()
	
	entity_movement.compute_movement(entity, delta)
	
	ability_manager.update_abilities(entity, delta)
	
	for ability in abilities.values():
		if ability is AbilityRes:
			ability._act(self, delta)
	
	if !entity.move_paused:
		velocity = entity.body_vel
	else:
		velocity = Vector2.ZERO
	
	## debug
	#debug_prints()
	
	if !entity.move_paused:
		move_and_slide()
	
func _on_platform(platform: PlatformBasic, collider: CharacterBody2D) -> void:
	if collider.name == "PlayerNew":
		#%PlatformBehavior.is_on_platform = true
		entity.is_on_platform = true
		#if %AirDodge.ad_initiated && entity.body_vel.y > 0.0:
		if abilities["AirDodge"].ad_initiated && entity.body_vel.y > 0.0:
			position.y = platform.position.y
		
func _on_hit_something(_hitbox: Node2D, _hurtbox: Node2D):
	entity.hit_connected = true
	
func debug_prints():
	print(str(name) + " -> current move state: " + str(entity.MoveState.keys()[entity.current_state]))
	print(str(name) + " -> entity.on_ground = " + str(entity.on_ground))
	#print(str(name) + " -> is on platform: " + str(entity.is_on_platform))
	#print("Move state frame count: " + str(entity.move_state_frame))
	#print(str(name) + " -> is on ground: " + str(entity.body_on_ground))
	
	#print(str(name) + " -> current move state: " + str(movement_manager.MoveState.keys()[movement_manager.current_state]))
	#print(str(name) + " -> current move state: " + str(movement.MoveState.keys()[movement.current_state]))
	#print(str(name) + " -> current velocity: " + str(movement.body_vel))
	#print(str(name) + " -> current move frame: " + str(movement.frame))
	#print(str(name) + " -> current friction value: " + str(movement_manager.calc_friction()))
	#print(str(name) + " -> direction.x: " + str(movement_manager.direction.x))
	#print(str(name) + " -> direction.y: " + str(movement_manager.direction.y))
	#print(str(name) + " -> orientation: " + str(movement_manager.orientation))
	#print(str(name) + " -> full crouch threshold: " + str(-deadzone + -crouch_thresh))
	#print(str(name) + " -> accel: " + str(accel))
	#print(str(name) + " -> current velocity: " + str(velocity))
	#print(str(name) + " -> current x input: " + str(movement_manager.direction.x))
	#print(str(name) + " -> dot product: " + str(movement_manager.direction.dot(body.velocity.normalized())))
	#print(str(name) + " -> deadzone: " + str(movement_manager.deadzone))
	#print(str(name) + " -> velocity length: " + str(velocity.length()))
	#print(str(name) + " -> frame #: " + str(movement_manager.frame))
