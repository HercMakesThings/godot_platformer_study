class_name Player
extends CharacterBody2D

#const SPEED = 200.0
@export var speed: float = 200.0
const MAX_SPEED: float = 400.0
#const JUMP_VELOCITY = -300.0
const JUMP_VELOCITY = -1000.0
const TERMINAL_VELOCITY = 250.0
@onready var fsm = $FSM
var dir: int = 1
var prev_dir: int
var accel: Vector2
var air_accel: Vector2
var mass: float = 5.0
var attack_flag: bool = false
var fr_force = Vector2(0,0)
var fr_threshold = 20
var friction = 0.45
var air_friction = 0.8
var air_drift: Vector2
var inertia: Vector2
var is_running: bool
var is_aerial: bool
var weight: float
var on_ground: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity

@onready var animated_sprite = $AnimatedSprite2D

@onready var hitbox = $Hitbox


func _ready():
	gravity = GRAVITY
	prev_dir = dir
	inertia = Vector2(0,0)
	air_drift = Vector2(0,0)
	weight = gravity * mass
	
	fsm.find_child("PlayerMove").is_player_moving.connect(_on_player_moving)
	fsm.find_child("PlayerJumpSquat").is_player_jumping.connect(_on_player_jumping)
	fsm.find_child("PlayerBasicAttack").is_player_attacking.connect(_on_player_attacking)
	fsm.find_child("PlayerDamaged").is_in_hitlag.connect(_on_player_under_hitlag)
	fsm.find_child("PlayerDamaged").is_in_hitstun.connect(_on_player_under_hitstun)
	fsm.find_child("PlayerLandingLag").is_in_landing_lag.connect(_on_player_under_landing_lag)
	
func _on_player_moving(direction, delta):
	if dir != 0 and is_on_floor():
		prev_dir = dir
	dir = direction
	is_running = true
	#print("direction: " + str(direction))
	#print("dir: " + str(dir))
	#print("prev_dir: " + str(prev_dir))
	var run_force = Vector2(150,0)
	air_drift = run_force * 0.5
	accel = calc_accel(run_force)
		
func _on_player_jumping(type):
	if type == "high":
		#velocity.y = JUMP_VELOCITY
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY))
		#velocity = velocity + air_accel * 2
		#velocity.y = move_toward(velocity.y, air_accel.y, 5)
		velocity.y = velocity.y + air_accel.y * 2
	if type == "short":
		#velocity.y = JUMP_VELOCITY*0.65
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
		#velocity = velocity + air_accel * 2
		#velocity.y = move_toward(velocity.y, air_accel.y, 5)
		velocity.y = velocity.y + air_accel.y * 2

func _on_player_attacking():
	attack_flag = true
	
func _on_player_under_landing_lag():
	velocity = velocity.lerp(Vector2(0,0), 0.1)
	#velocity.x = 0
	
func _physics_process(delta):
	#hitbox.set_process_mode(PROCESS_MODE_DISABLED)
	#print("hello from physics process")
	if not is_on_floor():
		is_aerial = true
		on_ground = false
		#velocity.y += (gravity * 0.6) * delta
		if velocity.y < TERMINAL_VELOCITY:
			#velocity += (Vector2(0, weight) * 0.6) * delta
			#velocity = velocity.lerp(Vector2(0, TERMINAL_VELOCITY), 0.1)
			#velocity.y = move_toward(0, TERMINAL_VELOCITY, 0.1)
			velocity.y = velocity.y + 20
		else:
			velocity.y = TERMINAL_VELOCITY
		if velocity.x <= MAX_SPEED:
			pass
	else:
		if !on_ground:
			fsm.force_change_state("PlayerLandingLag")
		on_ground = true
		
	if attack_flag and is_on_floor():
		is_running = false
		#velocity.x = lerp(velocity.x, float(0), 0.25)
		#velocity.x = velocity.x * 0.80
		velocity.x = velocity.x - (5 * dir)
		if abs(velocity.x) < 120:
			attack_flag = false
			velocity.x = 0
		
	if is_running:
		#velocity = velocity + accel
		if is_on_floor():
			#velocity = (velocity + accel * 10 * dir) * friction * delta
			if abs(velocity.x) < MAX_SPEED * delta:
				velocity = (velocity + accel * 30 * dir * delta * friction)
			else:
				velocity.x = MAX_SPEED * delta * dir * 30
		else:
				var accel_mag = accel.length()
			#velocity = (velocity + accel * 10 * dir) * air_friction * delta
			#if abs(velocity.x) < MAX_SPEED * delta:
				#air_drift.x * dir
				#accel = accel + (air_drift * 300)
				#velocity = (velocity + accel * 300 * dir * delta * air_friction)
				if dir == prev_dir || prev_dir == 0:
					#velocity = (velocity + accel * 80 * dir * delta)
					pass
				else:
					#velocity = (velocity + accel * 40 * dir * delta)
					#accel = accel * 0.65
					#accel = accel.lerp(accel * 0.35, 0.01)
					#var accel_mag = accel.length()
					#if accel_mag != 0:
					accel_mag = move_toward(accel_mag, 0, 0.01)
					accel = accel.normalized() * accel_mag
					#velocity = (velocity + accel * 80 * dir * delta)
					#accel = accel - (accel * 2 * dir)
					#velocity = velocity.lerp(velocity * dir, air_friction)
				velocity = (velocity + accel * 80 * dir * delta)
				velocity.x = velocity.x * air_friction
				#velocity = (velocity + accel * 30 * dir * delta * air_friction) + ((air_drift * 300) * dir)
			#else:
				##velocity.Sx = MAX_SPEED * delta * dir * 30
				##air_drift.x * dir
				##accel = accel + (air_drift * 30)
				#velocity.x = move_toward(velocity.x, 0, 0.25)
				##velocity.x = move_toward(velocity.x, air_drift.x, 0.25)
		if abs(velocity.x) == 0:
			#velocity.x = 0d
			is_running = false
		#print("pong")
	#is_running = false
	else:
		#velocity = velocity.lerp(Vector2(0,0), 0.01)
		#velocity.x = move_toward(velocity.x, 0, 0.1)
		#print("ping")
		velocity.x = velocity.x - (5 * dir) * delta
		accel = accel.lerp(Vector2(0,0), 1)
		#print("horizontal vel: " + str(velocity.x))
		#print("horizontal accel: " + str(accel.x))
	#print(is_running)
	#print("dir: " + str(dir))
	#print("prev_dir: " + str(prev_dir))
	is_running = false
	move_and_slide()
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass


func _on_hurtbox_area_entered(area):
	if area.is_in_group("atk_hitbox_group"):
		#print("ouch!")
		#print(area.dmg)
		fsm.force_change_state("PlayerDamaged")
		
func _on_player_under_hitlag(delta):
	velocity.x = 0
	velocity.y = 0
	gravity = 0
	
func _on_player_under_hitstun(delta):
	if gravity == 0:
		gravity = GRAVITY
	var force = Vector2(-5,-5).normalized()
	#var force = Vector2(-5,-5)
	#force * 200
	accel = calc_accel(force)
	#if velocity.x < MAX_SPEED*1.5:
		#velocity = (velocity + accel) * delta * 60
		#velocity = (velocity + (accel*20) * 60 * delta)
		#velocity.x = velocity.x - 5
	#elif velocity.x >= MAX_SPEED:
		#velocity.x = move_toward(MAX_SPEED, 0, 1)
		#inertia = accel*20
	velocity = (velocity + (accel*100) * 60 * delta)
	inertia = accel*100
	#inertia = accel.from_angle(get_angle_to(accel))*100
	
