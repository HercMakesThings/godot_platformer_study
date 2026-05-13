class_name Article extends Node2D

@export var ecb: EnvironmentCollisionBody
@export var hurtbox: Hurtbox
@export var input_game_component: InputGameComponent
@export var entity: Entity
@export var entity_movement: EntityMoveRes
@export var status: EntityStatus
@export var abilities: Dictionary[String, AbilityRes]

@export var TIMERS: Node
var timers: Dictionary[String, Timer]

@export var model: Node

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.ZERO
	entity.init()
	status.init_health(self)
	for i in abilities:
		abilities[i]._init_ability(self)
	if TIMERS.get_child_count() > 0:
		for timer in TIMERS.get_children():
			timers[timer.name] = timer
		
func _physics_process(delta: float) -> void:
	ecb.tick(self)
	
	# capture player input
	input_game_component.update()
	
	entity.jump_pressed = input_game_component.btn_3_input
	entity.jump_just_pressed = input_game_component.btn_3_just_pressed
	entity.jump_released = input_game_component.btn_3_input_released
	entity.direction = input_game_component.dir_input
	
	entity_movement.compute_movement(entity, delta)
	
	for ability: AbilityRes in abilities.values():
		ability._act(self, delta)
		
	handle_velocity(delta)
	
	## debug prints
	#debug_prints()
	
func handle_velocity(delta: float) -> void:
	if !entity.move_paused:
		velocity = entity.body_vel
	else:
		velocity = Vector2.ZERO
	position = position + velocity * delta
	
func debug_prints():
	print(str(name) + " -> current movement state: " + str(entity.MoveState.keys()[entity.current_state]))
	#print(str(name) + " -> body is on ground: " + str(entity.body_on_ground))
	#print(str(name) + " -> body is on platform: " + str(entity.is_on_platform))
