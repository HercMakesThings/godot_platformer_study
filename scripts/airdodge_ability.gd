class_name Airdodge extends Ability

#@onready var body: PlayerNew = $"../.."
@export var body: CharacterBody2D
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

#func tick_ability(input: InputGameComponent, movement: MovementComponent, _delta: float) -> void:
func tick_ability(movement: MovementComponent, _delta: float) -> void:
	#print("can move: " + str(movement.can_move))
	if (input.guard_input && air_dodge > 0 &&
		(movement.current_state == movement.MoveState.AIRBORNE ||
		 movement.current_state == movement.MoveState.JUMPSQUAT)):
			ad_initiated = true
			ad_direction = Vector2(
				movement.direction.x,
				-movement.direction.y
			).normalized()
			movement.can_move = false
			air_dodge -= 1
			
	if ad_initiated:
		#print("ad frame: " + str(ad_frame))
		#if ad_frame == 1:
			#flash_timer.start()
			#model.material.set_shader_parameter("flash_modifier", 0.6)
		##if movement.current_state == movement.MoveState.LANDLAG:
			##ad_initiated = false
			##ad_frame = 0
			##movement.can_move = true
			##return
		##if body.is_on_floor():
			##if !movement.contact_point.is_colliding():
				##ad_initiated = false
				##ad_frame = 0
				##movement.can_move = true
				##return
		#if ad_frame < 10:
			#if body.is_on_floor():
				##body.velocity = ad_direction * 5000 * delta
				#body.velocity = ad_direction * 500
			#else:
				#body.velocity = ad_direction * 450
		#if ad_frame >= 10:
			#if body.is_on_floor():
				#body.velocity = lerp(body.velocity, Vector2(0,0), 0.05)
			##velocity = lerp(velocity, Vector2(0,0), body.friction)
			#else:
				#body.velocity = lerp(body.velocity, Vector2(0,0), 0.5)
		#if ad_frame >= air_dodge_length:
			#movement.can_move = true
			#ad_frame = 0
			#ad_initiated = false
			
		if ad_frame == 1:
			flash_timer.start()
			model.material.set_shader_parameter("flash_modifier", 0.6)
		if body.is_on_floor():
			#if air_dodge < air_dodge_count:
				#air_dodge = air_dodge_count
			if !touched_ground:
				## comment out the if statement below to enable superjump.
				## is that a good idea?? not sure yet
				if movement.current_state != movement.MoveState.JUMPSQUAT:
					touched_ground = true
			#if !movement.contact_point.is_colliding():
			##if !movement.on_ground:
				#movement.can_move = true
				#ad_frame = 0
				#ad_initiated = false
				##_on_flash_timer_timeout()
				#flash_timer.stop()
				#flash_timer.timeout.emit()
				#return
			if air_dodge < air_dodge_count:
				air_dodge = air_dodge_count
			if ad_frame <= air_dodge_length - air_dodge_landlag:
				body.velocity = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length:
				#body.velocity = lerp(body.velocity, Vector2(0,0), smoothstep(1.0, 0.0, clampf(movement.friction, 0, 1)))
				#body.velocity = lerp(body.velocity, Vector2(0,0), smoothstep(1.0, 0.0, clampf(movement.calc_friction(), 0, 1)))
				body.velocity = body.velocity.move_toward(Vector2.ZERO, movement.calc_friction())
				#body.velocity = body.velocity.move_toward(Vector2.ZERO, movement.accel_mag)
			else:
				movement.can_move = true
				ad_frame = 0
				ad_initiated = false
				if air_dodge < air_dodge_count && touched_ground:
					air_dodge = air_dodge_count
				touched_ground = false
				return
		else:
			if touched_ground:
				movement.can_move = true
				ad_frame = 0
				ad_initiated = false
				touched_ground = false
				
				air_dodge = air_dodge_count
				
				flash_timer.stop()
				flash_timer.timeout.emit()
				return
			if ad_frame < air_dodge_length - air_dodge_landlag:
			#if ad_frame < air_dodge_length:
				body.velocity = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length:
					#body.velocity = lerp(body.velocity, Vector2(0,0), smoothstep(0.0, 1.0, 0.5))
					body.velocity = body.velocity.slerp(Vector2.ZERO, smoothstep(0.0, 1.0, 0.5))
			elif ad_frame >= air_dodge_length + 10:
				movement.can_move = true
				ad_frame = 0
				touched_ground = false
				ad_initiated = false
				return
			else:
				movement.can_move = true
		ad_frame += 1
		return
				
	if (body.is_on_floor() && air_dodge < air_dodge_count):
		air_dodge = air_dodge_count
				


func _on_flash_timer_timeout() -> void:
	model.material.set_shader_parameter("flash_modifier", 0.0)
