class_name Sandbag extends CharacterBody2D

@onready var movement_manager: MovementManager = %MovementManager
@onready var health_manager: HealthManager = %HealthManager
@onready var ability_manager: AbilityManager = %AbilityManager
@onready var platform_manager: PlatformManager = $"../PlatformManager"
@onready var contact_point: RayCast2D = $ContactPoint

@export var movement: MovementRes
@export var entity_movement: EntityMoveRes

@export var entity: Entity

@export var abilities: Dictionary[String, AbilityRes]

func _ready() -> void:
	platform_manager._pl_on_platform.connect(_on_platform)
	entity.init()
	for i in abilities:
		abilities[i]._init_ability(self)
		print(str(name) + " Ability Resource: " + str(abilities[i].name))

func _physics_process(delta: float) -> void:
	#movement_manager.tick(delta)
	entity.contact_point = contact_point.is_colliding()
	entity.body_on_ground = is_on_floor()
	entity_movement.compute_movement(entity, delta)
	
	#ability_manager.update_abilities(input_game_component, movement_manager, delta)
	#ability_manager.update_abilities(movement_manager, delta)
	#ability_manager.update_abilities(movement, delta)
	#ability_manager.update_abilities(entity, delta)
	
	for ability in abilities.values():
		if ability is AbilityRes:
			ability._act(self, delta)
	
	if !entity.move_paused:
		velocity = entity.body_vel
	else:
		velocity = Vector2.ZERO
	
	#debug_prints()
	
	if !entity.move_paused:
		move_and_slide()
	
func _on_platform(_platform: PlatformBasic, collider: CharacterBody2D) -> void:
	if collider.name == "Sandbag":
		movement_manager.is_on_platform = true
		
func debug_prints():
	print(str(name) + " -> current movement state: " + str(entity.MoveState.keys()[entity.current_state]))
