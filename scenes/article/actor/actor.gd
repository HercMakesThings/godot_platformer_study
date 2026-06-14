class_name Actor extends Article

@export var input_component: InputComponent
@onready var item_spawn_location: Node2D = %ItemSpawnLocation

func _ready() -> void:
	super._ready()
	input_component.init()
		
func _physics_process(delta: float) -> void:
	# capture player input
	input_component.update()
	var packet: InputPacket = input_component.get_current_packet()
	entity.direction = packet.primary_direction
	entity.jump_pressed = packet.jump_pressed
	entity.jump_just_pressed = packet.jump_just_pressed
	entity.jump_released = packet.jump_just_released
	
	item_spawn_location.position.x = absf(item_spawn_location.position.x) * entity.orientation
	
	super._physics_process(delta)
