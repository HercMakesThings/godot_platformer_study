extends CharacterBody2D
class_name CrawlerEnemy

@export var orientation: int = 0
@export var mass: float = 4.0

const TERMINAL_VELOCITY := 350.0
@export var GRAVITY: int = 20
var gravity: int
var weight: float

@onready var atk_range = $AtkRange
@onready var collide_range = $CollideRange
@onready var fsm = $CrawlerFSMLite
@onready var ecb = $EnvironmentCollisionBox

@onready var hitbox_1 := $"hitboxes/Hitbox1"
@onready var hitbox_2 := $"hitboxes/Hitbox2"

@onready var hm := $HealthManager
@onready var sm := $StaminaManager

func _ready() -> void:
	gravity = GRAVITY
	weight = mass * gravity
	if orientation == 0:
		atk_range.target_position.x = -abs(atk_range.target_position.x)
		collide_range.target_position.x = -abs(collide_range.target_position.x)
	elif orientation == 1:
		atk_range.target_position.x = abs(atk_range.target_position.x)
		collide_range.target_position.x = abs(collide_range.target_position.x)
	
	#fsm.states["IdleState"].is_idling.connect(_on_idle)
	var is_idle = func(state: StateLite):
		return state.state_name.to_lower() == "idlestate"
	fsm.states.filter(is_idle)[0].is_idling.connect(_on_idle)
	
func _physics_process(delta: float) -> void:
	if orientation == 0:
		atk_range.target_position.x = -abs(atk_range.target_position.x)
		collide_range.target_position.x = -abs(collide_range.target_position.x)
	elif orientation == 1:
		atk_range.target_position.x = abs(atk_range.target_position.x)
		collide_range.target_position.x = abs(collide_range.target_position.x)
		
	hitbox_1.flip_hitbox(orientation)
	hitbox_2.flip_hitbox(orientation)
	
	match fsm.current_state.state_name:
		"IdleState":
			if is_on_floor():
				if collide_range.is_colliding():
					if collide_range.get_collider().name == "groundLayer":
						if orientation == 0:
							orientation = 1
						elif orientation == 1:
							orientation = 0
				if orientation == 0:
					velocity.x = -50
				elif orientation == 1:
					velocity.x = 50
			else:
				if velocity.y < TERMINAL_VELOCITY:
					velocity.y += gravity
				else:
					velocity.y = TERMINAL_VELOCITY
		"AttackState":
			if is_on_floor():
				velocity.x = 0
			else:
				if velocity.y < TERMINAL_VELOCITY:
					velocity.y += gravity
				else:
					velocity.y = TERMINAL_VELOCITY
			if fsm.current_state.frame:
				if fsm.current_state.frame > 8 && fsm.current_state.frame < 12:
					hitbox_1.shape.set_deferred("disabled", false)
					hitbox_2.shape.set_deferred("disabled", true)
				elif fsm.current_state.frame > 28 && fsm.current_state.frame < 32:
					hitbox_2.shape.set_deferred("disabled", false)
					hitbox_1.shape.set_deferred("disabled", true)
				else:
					hitbox_1.shape.set_deferred("disabled", true)
					hitbox_2.shape.set_deferred("disabled", true)
		"DamagedState":
			pass
		"DeathState":
			pass
	move_and_slide()
	
func _on_idle():
	#print("idling!")
	pass
