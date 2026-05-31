class_name Article extends Node2D

@export var ecb: EnvironmentCollisionBody
@export var hurtbox: Hurtbox

#@export var input_game_component: InputGameComponent
@export var input_component: InputComponent

@export var entity: Entity
#@export var entity_movement: EntityMoveRes
@export var status: EntityStatus
#@export var abilities: Dictionary[String, AbilityRes]

@export var _components: Array[BaseComponent]

@export var TIMERS: Node
var timers: Dictionary[String, Timer]

@export var model: Node

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.ZERO
	input_component.init()
	entity.init()
	status.init_health(self)
	_bind_components()
	#for i in abilities:
		#abilities[i]._init_ability(self)
	if TIMERS.get_child_count() > 0:
		for timer in TIMERS.get_children():
			timers[timer.name] = timer
		
func _physics_process(delta: float) -> void:
	ecb.tick(self, delta)
	
	# capture player input
	input_component.update()
	var packet: InputPacket = input_component.get_current_packet()
	entity.direction = packet.primary_direction
	entity.jump_pressed = packet.jump_pressed
	entity.jump_just_pressed = packet.jump_just_pressed
	entity.jump_released = packet.jump_just_released
	
	#entity_movement.compute_movement(entity, delta)
	
	#for ability: AbilityRes in abilities.values():
		#ability._act(self, delta)
		
	_update_components(delta)
		
	#handle_velocity(delta)
	call_deferred("handle_velocity", delta)
	
	## debug prints
	#debug_prints()
	
func handle_velocity(delta: float) -> void:
	if !entity.move_paused:
		velocity = entity.body_vel
	else:
		velocity = Vector2.ZERO
	position = position + velocity * delta
	
func _bind_components() -> void:
	for comp: BaseComponent in _components:
		comp.bind(self)
		
func _update_components(delta) -> void:
	for comp: BaseComponent in _components:
		comp.update(delta)
		
func get_component(req: Object) -> BaseComponent:
	for component: BaseComponent in _components:
		if is_instance_of(component, req):
			return component
	return null
	
func debug_prints():
	print(str(name) + " -> current movement state: " + str(entity.MoveState.keys()[entity.current_state]))
	#print(str(name) + " -> body is on ground: " + str(entity.body_on_ground))
	#print(str(name) + " -> body is on platform: " + str(entity.is_on_platform))
