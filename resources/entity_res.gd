class_name Entity extends Resource

@export_group("Stats")
@export var dash_speed: float = 300.0
@export var dash_time: int = 18
@export var walk_speed: float = 15.0
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
@export var decel: float = 40.0

@export var GRAVITY: float = 8.0
var gravity: float
var weight: float

@export_group("Controls")
@export var hard_press_thresh: float = 0.8
@export var deadzone: float = 0.15
@export var crouch_thresh: float = 0.15

@export_group("Model")
@export var texture_2D: Texture2D
@export var sprite_frames: SpriteFrames 
@export var texture_3D: Texture3D

@export_group("Environmental Collision Box")
@export var ecb_stats: EcbStatsRes


var walk_force: Vector2
var dash_force: Vector2
var run_force: Vector2

var jump_pressed: bool = false
var jump_just_pressed: bool = false
var jump_released: bool = false
var is_short_jump: bool = false

var on_ground: bool
var contact_point: bool
var body_on_ground: bool

var accel: Vector2 = Vector2.ZERO
var dir_normalized: Vector2i = Vector2i.ZERO
var direction: Vector2 = Vector2.ZERO
var orientation: int
var is_on_platform: bool
var can_move: bool
var move_paused: bool

var hit_connected: bool

## Set CharacterBody velocity to this in _physics_process after it is acted upon
var body_vel: Vector2 = Vector2.ZERO

var current_state: MoveState
var move_state_frame: int
enum MoveState {IDLE, WALK, DASH, RUN, RUNTURN, JUMPSQUAT, AIRBORNE, LANDLAG, CROUCH}

func init() -> void:
	#orientation = 1
	dir_normalized = Vector2(orientation, 0)
	move_state_frame = 0
	gravity = GRAVITY
	weight = mass * gravity
	can_move = true
	move_paused = false
	hit_connected = false
	walk_force = Vector2(walk_speed, 0)
	dash_force = Vector2(dash_speed, 0)
	run_force = Vector2(run_speed, 0)
	
## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: MoveState) -> void:
	move_state_frame = 0
	current_state = new
	
func apply_gravity(extra: float = 0) -> void:
	if body_vel.y <= TERMINAL_VELOCITY:
		body_vel.y = move_toward(body_vel.y, TERMINAL_VELOCITY, gravity + extra)
	body_vel.y = clamp(body_vel.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_accel(force: Vector2, delta: float, use_dir = true) -> void:
	accel = accel + calc_accel(force)
	if use_dir:
		var f: Vector2 = (body_vel + accel * direction)
		#var f: Vector2 = (body_vel + accel * calc_friction())*direction
		#body_vel = body_vel.move_toward(f, smoothstep(0, f.length(), delta * calc_friction()))
		#body_vel = body_vel.move_toward(f, f.length() * calc_friction() * delta)
		#body_vel = body_vel.move_toward(f, force.x * calc_friction() * delta)
		body_vel = body_vel.move_toward(f, force.x * calc_friction() * delta)
		#body_vel = body_vel.move_toward(f, force.x * delta)
	else:
		#var f: Vector2 = (body_vel + accel)
		#body_vel = body_vel.move_toward(f, f.length() * delta * calc_friction())
		#body_vel = body_vel.move_toward(f, force.x * calc_friction() * delta)
		print("body vel: " + str(body_vel))
		body_vel = body_vel.move_toward(Vector2(abs(force.x)*orientation, force.y), force.x * calc_friction() * delta)
		#body_vel = body_vel.move_toward(accel, accel.x * calc_friction() * delta)
		
func apply_force(force: Vector2, delta: float) -> void:
	#var f: Vector2 = Vector2(force.x*direction.x, force.y*direction.y) / mass
	var f: Vector2
	if direction.x > 0:
		f = Vector2(force.x*direction.ceil().x, force.y*direction.y)
	elif direction.x < 0:
		f = Vector2(force.x*direction.floor().x, force.y*direction.y)
		
	#body_vel = body_vel.move_toward(f, force.x*calc_friction() * delta)
	body_vel = body_vel.move_toward(f, f.length()*calc_friction() * delta)
	#body_vel = body_vel.move_toward(f, (force.x*calc_friction() * delta)/mass)
		
func decelerate(delta: float, mod: float = 1.0) -> void:
	body_vel.x = move_toward(body_vel.x, 0.0, decel * delta * mod * calc_friction())
	#body_vel.x = move_toward(body_vel.x, 0.0, decel * mod * calc_friction())
	accel = accel.slerp(Vector2(0,0), 0.2)
	
func calc_nForce() -> float:
	return mass * gravity
	
func calc_friction() -> float:
	var nf: float = calc_nForce()
	if body_on_ground:
		return nf * friction
	else:
		#return nf * (air_friction * 0.01)
		return nf * (air_friction * 0.05)
		#return nf * air_friction
		
func get_weight() -> float:
	weight = mass * gravity
	return weight
	
