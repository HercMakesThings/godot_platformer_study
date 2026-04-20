class_name Airdodge extends Ability

@export var input: Node

@export var model: Node

@export var air_dodge_count: int = 1
#@export var air_dodge_length: int = 16
#@export var air_dodge_landlag: int = 8
@export var air_dodge_length: int = 20
@export var air_dodge_landlag: int = 10
@export var air_dodge_speed: float = 400.0

@onready var flash_timer: Timer = $flash_timer


var air_dodge: int
var ad_frame: int
var ad_initiated: bool
var ad_direction: Vector2
var touched_ground: bool

func _ready() -> void:
	air_dodge = air_dodge_count
	ad_frame = 0
	ad_initiated = false
	touched_ground = false

#func tick_ability(input: InputGameComponent, entity: MovementComponent, _delta: float) -> void:
#func tick_ability(movement: MovementManager, _delta: float) -> void:
#func tick_ability(movement: MovementRes, _delta: float) -> void:
func tick_ability(entity: Entity, delta: float) -> void:
	#if ((input.guard_input || input.is_guard_held()) && 
	if (input.guard_input && 
		air_dodge > 0 &&
		(entity.current_state == entity.MoveState.AIRBORNE ||
		 entity.current_state == entity.MoveState.JUMPSQUAT)
	):
		ad_initiated = true
		ad_direction = Vector2(
			entity.direction.x,
			-entity.direction.y
		).normalized()
		entity.can_move = false
		air_dodge -= 1
			
	if ad_initiated:
		if ad_frame == 1:
			flash_timer.start()
			model.material.set_shader_parameter("flash_modifier", 0.6)
		if entity.body_on_ground:
			if !touched_ground:
				if entity.current_state != entity.MoveState.JUMPSQUAT:
					touched_ground = true
			if air_dodge < air_dodge_count:
				air_dodge = air_dodge_count
			if entity.is_on_platform:
				entity.body_vel.y = 0.0
			if ad_frame <= air_dodge_length - air_dodge_landlag:
				entity.body_vel = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length && ad_frame >= air_dodge_landlag:
				if entity.is_on_platform:
					entity.decelerate(delta, 5.0)
				else:
					entity.decelerate(delta)
			else:
				entity.can_move = true
				ad_frame = 0
				ad_initiated = false
				if air_dodge < air_dodge_count && touched_ground:
					air_dodge = air_dodge_count
				touched_ground = false
				return
		else:
			if touched_ground && !entity.contact_point:
				entity.can_move = true
				ad_frame = 0
				ad_initiated = false
				touched_ground = false
				air_dodge = air_dodge_count
				
				flash_timer.stop()
				flash_timer.timeout.emit()
				return
			#if entity.is_on_platform && !entity.contact_point:
				#pass
			if ad_frame < air_dodge_length - air_dodge_landlag:
				entity.body_vel = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length:
					entity.body_vel = entity.body_vel.slerp(Vector2.ZERO, smoothstep(0.0, 1.0, 0.5))
			elif ad_frame >= air_dodge_length + 10:
				entity.can_move = true
				ad_frame = 0
				touched_ground = false
				ad_initiated = false
				return
			else:
				entity.can_move = true
				ad_frame = 0
				touched_ground = false
				ad_initiated = false
				return
			touched_ground = false
		ad_frame += 1
		return
				
	if (entity.body_on_ground && air_dodge < air_dodge_count):
		air_dodge = air_dodge_count
				


func _on_flash_timer_timeout() -> void:
	model.material.set_shader_parameter("flash_modifier", 0.0)
