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

@export var dash_speed := 150.0
@export var dash_time := 16
@export var walk_speed := 15.0
@export var run_speed := 45.0
@export var MAX_SPEED := 200.0
@export var MAX_AIR_SPEED := 175.0
@export var MAX_WALK_SPD := 60.0
@export var JUMP_VELOCITY := -250.0
@export var LANDING_LAG := 3
@export var mass := 5.0
@export var fr_force := Vector2.ZERO
@export var fr_threshold := 20.0
@export_range(0.0, 1, 0.05) var friction := 0.6
@export_range(0.0, 1, 0.05) var air_friction := 0.075
@export var TERMINAL_VELOCITY := 350.0
@export var extra_jump := 1

var hard_press_thresh := 0.8
var deadzone := 0.15
var crouch_thresh := 0.15

#var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var GRAVITY := 8.0
var gravity: float

var will_jump := false
var on_ground: bool

@export var decel := 400.0
var accel := Vector2.ZERO
#var air_accel := Vector2.ZERO
var dir_normalized := Vector2i.ZERO
var direction := Vector2.ZERO
var orientation: int
enum MoveState {IDLE, WALK, DASH, RUN, RUNTURN, JUMPSQUAT, AIRBORNE, LANDLAG, CROUCH}
var current_state: MoveState
var frame: int
var is_on_platform: bool
var can_move: bool
var move_paused: bool

func _ready() -> void:
	current_state = MoveState.IDLE if body.is_on_floor() else MoveState.AIRBORNE
	orientation = 1
	dir_normalized = Vector2(orientation, 0)
	frame = 0
	gravity = GRAVITY
	on_ground = body.is_on_floor()
	can_move = true
	move_paused = false

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
		#if ecb.disabled && !body.is_on_floor():
			#ecb.disabled = false
			
	if (current_state == MoveState.WALK || 
		current_state == MoveState.DASH || 
		current_state == MoveState.RUN ||
		current_state == MoveState.IDLE ||
		current_state == MoveState.JUMPSQUAT):
		if direction.x > 0.0:
			orientation = 1
		elif direction.x < 0.0:
			orientation = -1
	#print("curr state val: " + str(current_state))
	print("direction.x: " + str(direction.x))
	#print("direction.y: " + str(direction.y))
	#print("orientation: " + str(orientation))
	#print("full crouch threshold: " + str(-deadzone + -crouch_thresh))
	
	## early return for when ability or game mechanic needs
	## to pause the character entirely
	if move_paused:
		return
	
	if body.is_on_floor():
		if !on_ground:
			if !contact_point.is_colliding():
				change_state(MoveState.IDLE)
			else:
				change_state(MoveState.LANDLAG)
		on_ground = true
		if extra_jump == 0:
			extra_jump = 1
	else:
		on_ground = false
		if !contact_point.is_colliding():
			ecb.disabled = false
		
	handle_state(current_state, delta)
	
	frame = frame + 1
	print("current movement state: " + str(MoveState.keys()[current_state]))
	
	if (current_state == MoveState.WALK || 
		current_state == MoveState.DASH || 
		current_state == MoveState.RUN ||
		current_state == MoveState.CROUCH ||
		current_state == MoveState.LANDLAG):
		if abs(direction.x) < deadzone:
			print("test!")
			body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta * 5)
			accel = accel.slerp(Vector2(0,0), 1)
			if body.velocity.x == 0.0 && current_state != MoveState.CROUCH:
				change_state(MoveState.IDLE)
				print("current movement state: " + str(MoveState.keys()[current_state]))
				return
	
## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: MoveState):
	current_state = new
	frame = 0
	
func handle_state(state: MoveState, delta: float) -> void:
	match state:
		MoveState.IDLE:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("idle")
				if abs(direction.x) > deadzone:
					change_state(MoveState.WALK)
					return
				#body.velocity.x = move_toward(body.velocity.x, 0.0, 5)
				body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta)
				accel = accel.lerp(Vector2(0,0), 1)
				
				if !can_move:
					return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y <= -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
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
				if abs(body.velocity.x) < MAX_WALK_SPD && can_move:
					#velocity = (velocity + accel * x_dir_raw * friction * delta)
					apply_force(Vector2(walk_speed, 0))
					apply_accel(delta)
				#else:
					#body.velocity.x = MAX_WALK_SPD * orientation
				if !can_move:
					return
				if frame < 3 && abs(direction.x) >= hard_press_thresh:
					change_state(MoveState.DASH)
					return
				if abs(direction.x) < deadzone:
					change_state(MoveState.IDLE)
					return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
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
				if abs(body.velocity.x) < MAX_SPEED && can_move:
					apply_force(Vector2(dash_speed, 0))
					apply_accel(delta)
				#else:
					#body.velocity.x = MAX_SPEED * orientation
				if !can_move:
					return
				if direction.dot(body.velocity) < 0:
					#body.velocity.x *= -1
					#frame = 0
					body.velocity.x = 0
					accel.x = 0
					change_state(MoveState.IDLE)
					return
				if frame >= dash_time:
					if abs(direction.x) >= hard_press_thresh:
						change_state(MoveState.RUN)
						return
					elif abs(direction.x) > deadzone:
						change_state(MoveState.WALK)
						return
					else:
						change_state(MoveState.IDLE)
						return
				#else:
					#if abs(direction.x) < hard_press_thresh && abs(direction.x) > deadzone:
						#change_state(MoveState.WALK)
						#return
					#elif abs(direction.x) < deadzone:
						#change_state(MoveState.IDLE)
						#return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
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
				if abs(body.velocity.x) < MAX_SPEED && can_move:
					apply_force(Vector2(run_speed, 0))
					apply_accel(delta)
				#else:
					#body.velocity.x = MAX_SPEED * orientation
				if !can_move:
					return
				#if abs(direction.x) > deadzone && abs(direction.x) < hard_press_thresh:
					#if direction.dot(body.velocity) < 0:
						#change_state(MoveState.RUNTURN)
						#return
					#else:
						#change_state(MoveState.WALK)
						#return
				#if abs(direction.x) < deadzone:
					#change_state(MoveState.IDLE)
					#return
				#elif (direction.x * orientation) < 0:
				if direction.dot(body.velocity) < 0:
					change_state(MoveState.RUNTURN)
					return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				if direction.y < -deadzone + -crouch_thresh:
					change_state(MoveState.CROUCH)
					return
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
				#if abs(direction.x) > deadzone && abs(direction.x) < hard_press_thresh:
					#change_state(MoveState.WALK)
					#return
				if !can_move:
					return
				if abs(direction.x) < deadzone:
					change_state(MoveState.IDLE)
					return
				#elif body.velocity.x == 0.0:
					#change_state(MoveState.RUN)
					#return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
				#if direction == Vector2.ZERO or direction.dot(body.velocity) < 0:
				if direction.dot(body.velocity) < 0:
					body.velocity = body.velocity.move_toward(Vector2.ZERO, decel * delta)
				elif body.velocity.x == 0.0:
					change_state(MoveState.RUN)
					return
				#else:
					#body.velocity = body.velocity.move_toward(Vector2(orientation * dash_speed, 0), accel.x * delta)
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		MoveState.JUMPSQUAT:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("jump_squat")
				if frame >= 4:
					if will_jump:
						#apply_force(Vector2(0,JUMP_VELOCITY))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY))
						#apply_accel(delta)
						body.velocity.y = JUMP_VELOCITY
						change_state(MoveState.AIRBORNE)
						return
					else:
						#apply_force(Vector2(0,JUMP_VELOCITY*0.65))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
						#apply_accel(delta)
						body.velocity.y = JUMP_VELOCITY*0.65
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
					if !contact_point.is_colliding():
						change_state(MoveState.IDLE)
						return
					else:
						change_state(MoveState.LANDLAG)
						return
				on_ground = true
				if extra_jump == 0:
					extra_jump = 1
			else:
				apply_gravity()
				if !can_move:
					return
				if abs(body.velocity.x) < MAX_AIR_SPEED:
					apply_force(Vector2(dash_speed, 0))
					apply_accel(delta)
				elif direction.dot(body.velocity) < 0:
					#apply_force(Vector2(dash_speed*0.005, 0))
					#apply_accel(delta)
					#body.velocity = body.velocity.move_toward(Vector2.ZERO, decel * delta * 5)
					body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta)
					accel = accel.lerp(Vector2(0,0), 1)
				#else:
					#body.velocity.x = MAX_SPEED * orientation
				if abs(direction.x) < deadzone:
					body.velocity.x = move_toward(body.velocity.x, 0, abs(body.velocity.x*0.05))
					#body.velocity.x = move_toward(body.velocity.x, 0, 2)
				is_on_platform = false
				#apply_gravity()
		MoveState.LANDLAG:
			if body.is_on_floor():
				if model is AnimatedSprite2D:
					model.play("landing_lag")
				if frame >= LANDING_LAG:
					change_state(MoveState.IDLE)
					return
				else:
					#body.velocity = body.velocity.lerp(Vector2(0,0), 0.1)
					body.velocity.x = move_toward(body.velocity.x, 0.0, decel * delta)
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
				if !can_move:
					return
				if direction.y >= -deadzone + -crouch_thresh:
					change_state(MoveState.IDLE)
					return
				if will_jump:
					will_jump = false
					change_state(MoveState.JUMPSQUAT)
					return
			else:
				on_ground = false
				change_state(MoveState.AIRBORNE)
				return
		
func apply_gravity(extra: float = 0) -> void:
	if body.velocity.y < TERMINAL_VELOCITY:
		body.velocity.y += (gravity + extra)
	else:
		body.velocity.y = TERMINAL_VELOCITY
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2):
	accel = accel + calc_accel(force)
	
func apply_accel(delta: float) -> void:
	#body.velocity = (body.velocity + accel * 300 * direction * fr)
	#body.velocity = (body.velocity + accel * direction * fr)
	body.velocity = (body.velocity + accel * direction * calc_friction() * delta)
	
func calc_nForce() -> float:
	return mass * gravity
	
func calc_friction() -> float:
	var nf: float = calc_nForce()
	if body.is_on_floor():
		return nf * friction
	else:
		return nf * air_friction
		
		
