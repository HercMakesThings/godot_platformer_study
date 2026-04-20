## This node handles basic movement for all entities in the game.
## It should be parented to the entity's CharacterBody2D or equivalent
## at the root node
class_name MovementRes extends Resource

## The parent Body the component controls.
## TODO: May refactor to signals instead
#@export var body: PhysicsBody2D
#@export var body: CharacterBody2D
## Visual representation of the entity.
## TODO: May refactor to signals instead
#@export var model: Node2D
#@export var model: Node
#@export var hurtbox: Hurtbox
#@export var ecb: EnvironmentCollisionBox
#@export var contact_point: RayCast2D

@export var dash_speed: float = 300.0
@export var dash_time: int = 18
@export var walk_speed: float = 15.0
#@export var run_speed: float = 40.0
@export var run_speed: float = 20.0
@export var MAX_SPEED: float= 300.0
@export var MAX_AIR_SPEED: float = 200.0
@export var MAX_WALK_SPD: float = 60.0
@export var JUMP_VELOCITY: float = -250.0
@export var SHORT_JUMP_MOD: float = 0.6
@export var LANDING_LAG: int = 3
@export var mass: float = 5.0
@export_range(0.0, 1, 0.0001) var friction: float = 0.45
@export_range(0.0, 1, 0.0001) var air_friction: float = 0.25
@export var TERMINAL_VELOCITY: float = 350.0
@export var STARTING_VELOCITY: Vector2 = Vector2.ZERO

var walk_force: Vector2
var dash_force: Vector2
var run_force: Vector2

var hard_press_thresh: float = 0.8
var deadzone: float = 0.1
var crouch_thresh: float = 0.15

#var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var GRAVITY: float = 8.0
var gravity: float
var weight: float

#var will_jump: bool = false
var jump_pressed: bool = false
var jump_just_pressed: bool = false
var jump_released: bool = false
var is_short_jump: bool = false
var on_ground: bool

var contact_point: bool
var body_on_ground: bool

#@export var decel: float = 400.0
@export var decel: float = 40.0
@export var accel_mag: float = 80.0
var accel: Vector2 = Vector2.ZERO
var dir_normalized: Vector2i = Vector2i.ZERO
var direction: Vector2 = Vector2.ZERO
var orientation: int
var current_state: MoveState
var frame: int
var is_on_platform: bool
var can_move: bool
var move_paused: bool

## Value returned when parent calls compute_val()
var body_vel: Vector2 = Vector2.ZERO

enum MoveState {IDLE, WALK, DASH, RUN, RUNTURN, JUMPSQUAT, AIRBORNE, LANDLAG, CROUCH}

func init() -> void:
	orientation = 1
	dir_normalized = Vector2(orientation, 0)
	frame = 0
	gravity = GRAVITY
	weight = mass * gravity
	#on_ground = body.is_on_floor()
	on_ground = is_on_ground()
	can_move = true
	move_paused = false
	walk_force = Vector2(walk_speed, 0)
	dash_force = Vector2(dash_speed, 0)
	run_force = Vector2(run_speed, 0)
	
## WARNING: Do not use this + tick_val(), use 1 or the other
func compute_movement(delta: float, dir: Vector2, is_body_on_ground: bool, contact_point_colliding: bool) -> Vector2:
	contact_point = contact_point_colliding
	body_on_ground = is_body_on_ground
	#if model is AnimatedSprite2D:
		#if orientation == -1:
			#model.flip_h = true
		#elif orientation == 1:
			#model.flip_h = false
	#if current_state != MoveState.CROUCH:
		#if model is ColorRect && model.size.y < 30:
			#model.size.y = 30
		#if hurtbox != null:
			#hurtbox.find_child("CollisionShape2D").scale.y = 1
			#hurtbox.find_child("CollisionShape2D").position.y = 0
	
	## early return for when ability or game mechanic needs
	## to pause the character entirely
	if move_paused:
		return Vector2.ZERO
	
	if STARTING_VELOCITY != Vector2.ZERO:
		body_vel = STARTING_VELOCITY
		STARTING_VELOCITY = Vector2.ZERO
	
	direction = dir
	
	handle_state(current_state, delta)
	frame = frame + 1
	return body_vel
	
## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: MoveState) -> void:
	frame = 0
	current_state = new
	
func handle_state(state: MoveState, delta: float) -> void:
	match state:
		MoveState.IDLE:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#model.play("idle")
				if !can_move:
					return
				if direction.x > deadzone:
					orientation = 1
				elif direction.x < -deadzone:
					orientation = -1
				if abs(direction.x) >= deadzone && abs(direction.x) < hard_press_thresh:
					change_state(MoveState.WALK)
					return
				elif abs(direction.x) >= hard_press_thresh:
					change_state(MoveState.DASH)
					return
				if jump_just_pressed || jump_pressed:
					#will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y <= -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				if body_vel.length() > 0.0:
					decelerate(delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.WALK:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#if orientation == -1:
						#model.play("walk_left")
					#elif orientation == 1:
						#model.play("walk_right")
				if !can_move:
					return
				if frame < 3 && abs(direction.x) >= hard_press_thresh:
					change_state(MoveState.DASH)
					return
				if abs(direction.x) < deadzone:
					if body_vel.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta, 5.0)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				apply_force(walk_force, delta)
				# Clamp speed
				body_vel.x = clamp(body_vel.x, -MAX_WALK_SPD, MAX_WALK_SPD)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.DASH:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#if orientation == -1:
						#model.play("walk_left")
					#elif orientation == 1:
						#model.play("walk_right")
				if !can_move:
					return
				if direction.dot(body_vel) < -deadzone && abs(direction.y) < deadzone:
					body_vel.x = 0
					accel = Vector2.ZERO
					change_state(MoveState.IDLE)
					return
				if frame >= dash_time:
					if abs(direction.x) >= hard_press_thresh:
						change_state(MoveState.RUN)
						return
				if abs(direction.x) < deadzone:
					if body_vel.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				apply_force(dash_force, delta)
				# Clamp speed
				body_vel.x = clamp(body_vel.x, -MAX_SPEED, MAX_SPEED)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.RUN:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#if orientation == -1:
						#model.play("walk_left")
					#elif orientation == 1:
						#model.play("walk_right")
				if !can_move:
					return
				if frame >= 3 && (orientation * direction.x) < 0:
					if direction.x > deadzone:
						orientation = 1
					elif direction.x < -deadzone:
						orientation = -1
				if direction.dot(body_vel) < -deadzone:
					change_state(MoveState.RUNTURN)
					return
				if abs(direction.x) < deadzone:
					if body_vel.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				apply_force(run_force, delta)
				# clamp speed
				body_vel.x = clamp(body_vel.x, -MAX_SPEED, MAX_SPEED)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.RUNTURN:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#if orientation == -1:
						#model.play("walk_left")
					#elif orientation == 1:
						#model.play("walk_right")
				if !can_move:
					return
				if direction.x > deadzone:
					orientation = 1
				elif direction.x < -deadzone:
					orientation = -1
				if abs(direction.x) < deadzone:
					if body_vel.length() < 1.0:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				if body_vel.x == 0.0:
					change_state(MoveState.RUN)
					return
				if direction.dot(body_vel) < 0:
					decelerate(delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.JUMPSQUAT:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#model.play("jump_squat")
				if jump_released:
					is_short_jump = true
				if frame >= 4:
					if is_short_jump:
						#apply_force(Vector2(0,JUMP_VELOCITY))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY))
						#apply_accel(delta)
						body_vel.y = JUMP_VELOCITY*SHORT_JUMP_MOD
						is_short_jump = false
						change_state(MoveState.AIRBORNE)
						return
					else:
						#apply_force(Vector2(0,JUMP_VELOCITY*0.65))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
						#apply_accel(delta)
						body_vel.y = JUMP_VELOCITY
						is_short_jump = false
						change_state(MoveState.AIRBORNE)
						return
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.AIRBORNE:
			#if model is AnimatedSprite2D:
				#model.play("in_air")
			#if body.is_on_floor():
			if is_on_ground():
				if body_vel.y > 0:
					body_vel.y = 0
				#if !on_ground:
					#on_ground = true
					##if !contact_point.is_colliding():
					#if !contact_point:
						#change_state(MoveState.IDLE)
						#return
					#else:
						#change_state(MoveState.LANDLAG)
						#return
				#else:
					#change_state(MoveState.LANDLAG)
					#return
				if !contact_point:
					change_state(MoveState.IDLE)
					return
				else:
					change_state(MoveState.LANDLAG)
					return
			else:
				apply_gravity()
				if !can_move:
					return
				## fast falling
				if body_vel.y >= 0.0:
					if (direction.y < -hard_press_thresh && 
						abs(direction.x) < deadzone &&
						can_move
					):
						body_vel.y = move_toward(body_vel.y, TERMINAL_VELOCITY, run_speed)
				apply_force(dash_force, delta)
				body_vel.x = clamp(body_vel.x, -MAX_AIR_SPEED, MAX_AIR_SPEED)
				#if ecb.disabled && !contact_point.is_colliding():
					#ecb.disabled = false
				#is_on_platform = false
		MoveState.LANDLAG:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#model.play("landing_lag")
				if frame >= LANDING_LAG:
					change_state(MoveState.IDLE)
					return
				else:
					decelerate(delta, 5.0)
					#decelerate(delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.CROUCH:
			#if body.is_on_floor():
			if is_on_ground():
				#if model is AnimatedSprite2D:
					#model.play("idle")
				#if model is ColorRect:
					#model.size.y = 15
				#if hurtbox != null:
					#hurtbox.find_child("CollisionShape2D").scale.y = 0.5
					#hurtbox.find_child("CollisionShape2D").position.y = 8.15
				if !can_move:
					return
				#if is_on_platform:
					#ecb.disabled = true
					#return
				if direction.y >= -deadzone + -crouch_thresh:
					change_state(MoveState.IDLE)
					return
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				decelerate(delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
	
func apply_gravity(extra: float = 0) -> void:
	if body_vel.y <= TERMINAL_VELOCITY:
		body_vel.y = move_toward(body_vel.y, TERMINAL_VELOCITY, gravity + extra)
	body_vel.y = clamp(body_vel.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2, delta: float, use_dir = true) -> void:
	accel = accel + calc_accel(force)
	if use_dir:
		var f: Vector2 = (body_vel + accel * direction * delta)
		body_vel = body_vel.move_toward(f, f.length()* calc_friction())
	else:
		var f: Vector2 = (body_vel + accel * calc_friction())
		body_vel = body_vel.move_toward(f, f.length() * delta * calc_friction())
		
func decelerate(delta: float, mod: float = 1.0) -> void:
	body_vel.x = move_toward(body_vel.x, 0.0, decel * delta * mod * calc_friction())
	accel = accel.slerp(Vector2(0,0), 0.2)
	
func calc_nForce() -> float:
	return mass * gravity
	
func calc_friction() -> float:
	var nf: float = calc_nForce()
	#if body.is_on_floor():
	if is_on_ground():
		return nf * friction
	else:
		return nf * (air_friction * 0.01)
		
func get_weight() -> float:
	weight = mass * gravity
	return weight
	
func is_on_ground() -> bool:
	#if body is RigidBody2D:
		#for bod in body.get_colliding_bodies():
			#if bod is TileMapLayer && bod.tile_set.get_physics_layer_collision_layer(0) == 2:
				#return true
		#return false
	#else:
		#return body.is_on_floor()
	return body_on_ground
