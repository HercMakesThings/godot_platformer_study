class_name AirDodge extends BaseComponent

@export var air_dodge_count: int = 1
@export var air_dodge_length: int = 20
@export var air_dodge_landlag: int = 10
@export var air_dodge_speed: float = 400.0

var air_dodge: int
var ad_frame: int
var ad_initiated: bool
var ad_direction: Vector2
var touched_ground: bool

func bind(node: Object) -> void:
	super.bind(node)
	air_dodge = air_dodge_count
	ad_frame = 0
	ad_initiated = false
	touched_ground = false
	
func update(delta: float) -> void:
	#if (actor.input_game_component.guard_input && 
	if (actor.input_component.get_current_packet().is_guard_just_pressed && 
		air_dodge > 0 &&
		(actor.entity.current_state == actor.entity.MoveState.AIRBORNE ||
		 actor.entity.current_state == actor.entity.MoveState.JUMPSQUAT)
	):
		ad_initiated = true
		ad_direction = Vector2(
			actor.entity.direction.x,
			-actor.entity.direction.y
		).normalized()
		actor.entity.can_move = false
		air_dodge -= 1
		#var timeout_callback: Callable = func(): _on_flash_timer_timeout(actor)
		#if !actor.timers.ad_flash_timer.timeout.is_connected(timeout_callback):
			#actor.timers.ad_flash_timer.timeout.connect(timeout_callback, Timer.CONNECT_ONE_SHOT)
		if !actor.timers.ad_flash_timer.timeout.is_connected(_on_flash_timer_timeout):
			actor.timers.ad_flash_timer.timeout.connect(_on_flash_timer_timeout, Timer.CONNECT_ONE_SHOT)
			
	if ad_initiated:
		if ad_frame == 1:
			actor.timers.ad_flash_timer.start()
			actor.model.material.set_shader_parameter("flash_modifier", 0.6)
			actor.entity.body_vel = ad_direction * air_dodge_speed
		if actor.entity.body_on_ground:
			if !touched_ground:
				if actor.entity.current_state != actor.entity.MoveState.JUMPSQUAT:
					touched_ground = true
			if air_dodge < air_dodge_count:
				air_dodge = air_dodge_count
			#actor.entity.decelerate(delta)
			if actor.entity.is_on_platform || actor.entity.body_on_ground:
				actor.entity.body_vel.y = 0.0
			if ad_frame <= air_dodge_length - air_dodge_landlag:
				actor.entity.body_vel = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length && ad_frame >= air_dodge_landlag:
				if actor.entity.is_on_platform:
					actor.entity.decelerate(delta, 5.0)
				else:
					actor.entity.decelerate(delta)
			else:
			#if ad_frame > air_dodge_length:
				actor.entity.can_move = true
				ad_frame = 0
				ad_initiated = false
				if air_dodge < air_dodge_count && touched_ground:
					air_dodge = air_dodge_count
				touched_ground = false
				return
		else:
			if touched_ground:
				actor.entity.can_move = true
				ad_frame = 0
				ad_initiated = false
				touched_ground = false
				air_dodge = air_dodge_count
				
				actor.timers.ad_flash_timer.stop()
				actor.timers.ad_flash_timer.timeout.emit()
				return
			
			## accessibility logic to snap actor to platform when
			## travelling down in order to make wavelanding easier
			#if actor.entity.body_vel.y > 0.0:
				#if actor.ecb.has_overlapping_areas():
					#for a in actor.ecb.get_overlapping_areas():
						#if a is PlatformNew:
							##print("snapping to platform!")
							#actor.position.y = a.position.y - a.collision_shape.size.y*0.5
			
			if ad_frame < air_dodge_length - air_dodge_landlag:
				actor.entity.body_vel = ad_direction * air_dodge_speed
			elif ad_frame < air_dodge_length:
					actor.entity.body_vel = actor.entity.body_vel.slerp(Vector2.ZERO, smoothstep(0.0, 1.0, 0.5))
			elif ad_frame >= air_dodge_length + 10:
				actor.entity.can_move = true
				ad_frame = 0
				touched_ground = false
				ad_initiated = false
				return
			else:
				actor.entity.can_move = true
				ad_frame = 0
				touched_ground = false
				ad_initiated = false
				return
			touched_ground = false
		ad_frame += 1
		return
				
	if (actor.entity.body_on_ground && air_dodge < air_dodge_count):
		air_dodge = air_dodge_count
		
func _on_flash_timer_timeout() -> void:
	actor.model.material.set_shader_parameter("flash_modifier", 0.0)
	
