class_name Article extends Node2D

@export var ecb: EnvironmentCollisionBody
@export var hurtbox: Hurtbox
@onready var hitboxes: Node2D = %Hitboxes

@export var entity: Entity
@export var status: EntityStatus

@export var _components: Array[BaseComponent]

@export var TIMERS: Node
var timers: Dictionary[String, Timer]

@export var model: Node

@export var debug: bool = false

var velocity: Vector2

func _ready() -> void:
	velocity = Vector2.ZERO 
	entity.init()
	_bind_components()
	if TIMERS.get_child_count() > 0:
		for timer in TIMERS.get_children():
			timers[timer.name] = timer
		
func _physics_process(delta: float) -> void:
	handle_velocity(delta)
	ecb.tick(self, delta)
		
	_update_components(delta)
		
	#handle_velocity(delta)
	#call_deferred("handle_velocity", delta)
	
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
		
func _update_components(delta: float) -> void:
	for comp: BaseComponent in _components:
		comp.update(delta)
		
func get_component(req: Object) -> BaseComponent:
	for component: BaseComponent in _components:
		if is_instance_of(component, req):
			return component
	return null
	
func debug_prints() -> void:
	print(str(name) + " -> current movement state: " + str(entity.MoveState.keys()[entity.current_state]))
	#print(str(name) + " -> body is on ground: " + str(entity.body_on_ground))
	#print(str(name) + " -> body is on platform: " + str(entity.is_on_platform))
