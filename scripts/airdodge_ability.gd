class_name Airdodge extends Ability

@onready var body: PlayerNew = $"../.."

@export var model: Node

@export var air_dodge_count: int = 1
@export var air_dodge_length: int = 16

@onready var flash_timer: Timer = $flash_timer


var air_dodge: int
var ad_frame: int
var ad_initiated: bool
var ad_direction: Vector2

func _ready() -> void:
	air_dodge = air_dodge_count
	ad_frame = 0
	ad_initiated = false

func tick_ability(input: InputGameComponent, movement: MovementComponent, _delta: float) -> void:
	if (input.guard_input && air_dodge > 0 &&
		(movement.current_state == movement.MoveState.AIRBORNE ||
		 movement.current_state == movement.MoveState.JUMPSQUAT)):
			ad_initiated = true
			#ad_direction = movement.direction.normalized()
			ad_direction = Vector2(movement.direction.x, -movement.direction.y).normalized()
			#ad_direction = movement.direction
			movement.can_move = false
			air_dodge -= 1
			
	if ad_initiated:
		#print("ad frame: " + str(ad_frame))
		if ad_frame == 1:
			flash_timer.start()
			model.material.set_shader_parameter("flash_modifier", 0.6)
		#if movement.current_state == movement.MoveState.LANDLAG:
			#ad_initiated = false
			#ad_frame = 0
			#movement.can_move = true
			#return
		#if body.is_on_floor():
			#if !movement.contact_point.is_colliding():
				#ad_initiated = false
				#ad_frame = 0
				#movement.can_move = true
				#return
		if ad_frame < 10:
			if body.is_on_floor():
				#body.velocity = ad_direction * 5000 * delta
				body.velocity = ad_direction * 500
			else:
				#body.velocity = ad_direction * 4500 * delta
				body.velocity = ad_direction * 450
		if ad_frame >= 10:
			if body.is_on_floor():
				body.velocity = lerp(body.velocity, Vector2(0,0), 0.05)
			#velocity = lerp(velocity, Vector2(0,0), friction)
			else:
				body.velocity = lerp(body.velocity, Vector2(0,0), 0.5)
		if ad_frame >= air_dodge_length:
			movement.can_move = true
			ad_frame = 0
			ad_initiated = false
		ad_frame += 1
		return
				
	if (body.is_on_floor() && air_dodge < air_dodge_count):
		air_dodge = air_dodge_count
				


func _on_flash_timer_timeout() -> void:
	model.material.set_shader_parameter("flash_modifier", 0.0)
