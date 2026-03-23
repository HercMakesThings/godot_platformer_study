## This node handles basic movement for all entities in the game.
## It should be parented to the entity's CharacterBody2D or equivalent
## at the root node
class_name MovementComponent extends Node

## The parent Body the component controls.
## TODO: May refactor to signals instead
@export var body: CharacterBody2D
## Visual representation of the entity.
## TODO: May refactor to signals instead
#@export var model: Node2D
@export var model: Node
@export var hurtbox: Hurtbox
@export var ecb: EnvironmentCollisionBox
@export var contact_point: RayCast2D

@export var dash_speed: float = 180.0
@export var dash_time: int = 18
@export var walk_speed: float = 15.0
#@export var run_speed: float = 40.0
@export var run_speed: float = 20.0
@export var MAX_SPEED: float= 200.0
@export var MAX_AIR_SPEED: float = 200.0
@export var MAX_WALK_SPD: float = 60.0
@export var JUMP_VELOCITY: float = -250.0
@export var SHORT_JUMP_MOD: float = 0.6
@export var LANDING_LAG: int = 3
@export var mass: float = 5.0
@export_range(0.0, 1, 0.05) var friction: float = 0.6
#@export_range(0.0, 1, 0.05) var friction: float = 0.2
#@export_range(0.0, 1, 0.05) var air_friction: float = 0.075
@export_range(0.0, 1, 0.05) var air_friction: float = 0.15
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

#@export var decel: float = 400.0
@export var decel: float = 40.0
var accel: Vector2 = Vector2.ZERO
var dir_normalized: Vector2i = Vector2i.ZERO
var direction: Vector2 = Vector2.ZERO
var orientation: int
var current_state: MoveState
var frame: int
var is_on_platform: bool
var can_move: bool
var move_paused: bool

enum MoveState {IDLE, WALK, DASH, RUN, RUNTURN, JUMPSQUAT, AIRBORNE, LANDLAG, CROUCH}

func _ready() -> void:
	orientation = 1
	dir_normalized = Vector2(orientation, 0)
	frame = 0
	gravity = GRAVITY
	weight = mass * gravity
	on_ground = body.is_on_floor()
	can_move = true
	move_paused = false
	walk_force = Vector2(walk_speed, 0)
	dash_force = Vector2(dash_speed, 0)
	run_force = Vector2(run_speed, 0)

func tick(delta: float) -> void:
	if body == null:
		return
	if model is AnimatedSprite2D:
		if orientation == -1:
			model.flip_h = true
		elif orientation == 1:
			model.flip_h = false
	if current_state != MoveState.CROUCH:
		if model is ColorRect && model.size.y < 30:
			model.size.y = 30
		hurtbox.find_child("CollisionShape2D").scale.y = 1
		hurtbox.find_child("CollisionShape2D").position.y = 0
		if ecb.disabled && !body.is_on_floor():
			ecb.disabled = false
	
	## early return for when ability or game mechanic needs
	## to pause the character entirely
	if move_paused:
		return
	
	if STARTING_VELOCITY != Vector2.ZERO:
		#apply_force(STARTING_VELOCITY)
		#apply_accel(delta)
		body.velocity = STARTING_VELOCITY
		STARTING_VELOCITY = Vector2.ZERO
	
	handle_state(current_state, delta)
	frame = frame + 1
	#print("current movement state: " + str(MoveState.keys()[current_state]) + ", entity: " + str(body.name))
	#accel = Vector2.ZERO
	
## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: MoveState) -> void:
	frame = 0
	current_state = new
	
func handle_state(state: MoveState, delta: float) -> void:
	match state:
		MoveState.IDLE:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("idle")
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
				if body.velocity.length() > 0.0:
					decelerate(delta)
					accel = accel.slerp(Vector2(0,0), 0.5)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.WALK:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					if orientation == -1:
						model.play("walk_left")
					elif orientation == 1:
						model.play("walk_right")
				if !can_move:
					return
				if frame < 3 && abs(direction.x) >= hard_press_thresh:
					change_state(MoveState.DASH)
					return
				if abs(direction.x) < deadzone:
					#if body.velocity == Vector2.ZERO:
					#if body.velocity.is_zero_approx() && frame >= 3:
					if body.velocity.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta, 5.0)
					#accel = accel.slerp(Vector2(0,0), 1)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				apply_force(walk_force, delta)
				# Clamp speed
				body.velocity.x = clamp(body.velocity.x, -MAX_WALK_SPD, MAX_WALK_SPD)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.DASH:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					if orientation == -1:
						model.play("walk_left")
					elif orientation == 1:
						model.play("walk_right")
				if !can_move:
					return
				#if direction.dot(body.velocity) < -deadzone:
				if direction.dot(body.velocity) < -deadzone && abs(direction.y) < deadzone:
					#body.velocity.x *= -1
					body.velocity.x = 0
					accel = Vector2.ZERO
					change_state(MoveState.IDLE)
					return
				if frame >= dash_time:
					if abs(direction.x) >= hard_press_thresh:
						change_state(MoveState.RUN)
						return
				if abs(direction.x) < deadzone:
					if body.velocity.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
					accel = accel.slerp(Vector2(0,0), 1)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				apply_force(dash_force, delta)
				# Clamp speed
				body.velocity.x = clamp(body.velocity.x, -MAX_SPEED, MAX_SPEED)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.RUN:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					if orientation == -1:
						model.play("walk_left")
					elif orientation == 1:
						model.play("walk_right")
				if !can_move:
					return
				if frame >= 3 && (orientation * direction.x) < 0:
					if direction.x > deadzone:
						orientation = 1
					elif direction.x < -deadzone:
						orientation = -1
				if direction.dot(body.velocity) < -deadzone:
					change_state(MoveState.RUNTURN)
					return
				if abs(direction.x) < deadzone:
					if body.velocity.length() < 1.0 && frame >= 3:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
					accel = accel.slerp(Vector2(0,0), 1)
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				apply_force(run_force, delta)
				body.velocity.x = clamp(body.velocity.x, -MAX_SPEED, MAX_SPEED)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.RUNTURN:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					if orientation == -1:
						model.play("walk_left")
					elif orientation == 1:
						model.play("walk_right")
				if !can_move:
					return
				if direction.x > deadzone:
					orientation = 1
				elif direction.x < -deadzone:
					orientation = -1
				if abs(direction.x) < deadzone:
					if body.velocity.length() < 1.0:
						change_state(MoveState.IDLE)
						return
					decelerate(delta)
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
				#if direction == Vector2.ZERO or direction.dot(body.velocity) < 0:
				if body.velocity.x == 0.0:
					change_state(MoveState.RUN)
					return
				if direction.dot(body.velocity) < 0:
					decelerate(delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.JUMPSQUAT:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("jump_squat")
				if jump_released:
					is_short_jump = true
				if frame >= 4:
					if is_short_jump:
						#apply_force(Vector2(0,JUMP_VELOCITY))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY))
						#apply_accel(delta)
						body.velocity.y = JUMP_VELOCITY*SHORT_JUMP_MOD
						is_short_jump = false
						change_state(MoveState.AIRBORNE)
						return
					else:
						#apply_force(Vector2(0,JUMP_VELOCITY*0.65))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
						#apply_accel(delta)
						body.velocity.y = JUMP_VELOCITY
						is_short_jump = false
						change_state(MoveState.AIRBORNE)
						return
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.AIRBORNE:
			if model is AnimatedSprite2D:
				model.play("in_air")
			if body.is_on_floor():
				if !on_ground:
					on_ground = true
					if !contact_point.is_colliding():
						change_state(MoveState.IDLE)
						return
					else:
						change_state(MoveState.LANDLAG)
						return
				else:
					change_state(MoveState.LANDLAG)
					return
			else:
				apply_gravity()
				if !can_move:
					return
				## fast falling
				if body.velocity.y >= 0.0:
					if (direction.y < -hard_press_thresh && 
						abs(direction.x) < deadzone &&
						can_move
					):
						body.velocity.y = move_toward(body.velocity.y, TERMINAL_VELOCITY, run_speed)
				apply_force(dash_force, delta)
				body.velocity.x = clamp(body.velocity.x, -MAX_AIR_SPEED, MAX_AIR_SPEED)
				is_on_platform = false
		MoveState.LANDLAG:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("landing_lag")
				if frame >= LANDING_LAG:
					change_state(MoveState.IDLE)
					return
				else:
					decelerate(delta, 5.0)
					accel = accel.lerp(Vector2(0,0), 1)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.CROUCH:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("idle")
				if model is ColorRect:
					model.size.y = 15
				hurtbox.find_child("CollisionShape2D").scale.y = 0.5
				hurtbox.find_child("CollisionShape2D").position.y = 8.15
				if is_on_platform:
					if ecb.disabled:
						ecb.disabled = false
						return
					ecb.disabled = true
				decelerate(delta)
				accel = accel.lerp(Vector2(0,0), 1)
				if !can_move:
					return
				if direction.y >= -deadzone + -crouch_thresh:
					change_state(MoveState.IDLE)
					return
				if jump_just_pressed || jump_pressed:
					change_state(MoveState.JUMPSQUAT)
					return
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		
func apply_gravity(extra: float = 0) -> void:
	if body.velocity.y <= TERMINAL_VELOCITY:
		body.velocity.y = move_toward(body.velocity.y, TERMINAL_VELOCITY, gravity + extra)
	body.velocity.y = clamp(body.velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2, delta: float, use_dir = true) -> void:
	accel = accel + calc_accel(force)
	if use_dir:
		var f: Vector2 = (body.velocity + accel * direction * calc_friction() * delta)
		body.velocity = body.velocity.move_toward(f, calc_friction())
	else:
		var f: Vector2 = (body.velocity + accel * calc_friction() * delta)
		#var f: Vector2 = (body.velocity + accel * delta)
		body.velocity = body.velocity.move_toward(f, calc_friction())
		
func decelerate(delta: float, mod: float = 1.0) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta * mod * calc_friction())
	#body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta * mod * friction)
	
func calc_nForce() -> float:
	return mass * gravity
	
func calc_friction() -> float:
	var nf: float = calc_nForce()
	if body.is_on_floor():
		return nf * friction
	else:
		return nf * air_friction
		
func get_weight() -> float:
	weight = mass * gravity
	return weight
