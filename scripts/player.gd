class_name Player
extends CharacterBody2D

#const SPEED = 200.0
@export var speed: float = 200.0
const MAX_SPEED: float = 400.0
const JUMP_VELOCITY = -300.0
@onready var fsm = $FSM
var dir: int = 1
var prev_dir: int
var accel: Vector2
var mass: float = 5.0
var attack_flag: bool = false
var fr_force = Vector2(0,0)
var fr_threshold = 20
var friction = 0.5
var air_friction = 0.95
var inertia: Vector2
var is_running: bool
var is_aerial: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	gravity = GRAVITY
	prev_dir = dir
	inertia = Vector2(0,0)
	
	fsm.find_child("PlayerMove").is_player_moving.connect(_on_player_moving)
	fsm.find_child("PlayerJumpSquat").is_player_jumping.connect(_on_player_jumping)
	fsm.find_child("PlayerBasicAttack").is_player_attacking.connect(_on_player_attacking)
	fsm.find_child("PlayerDamaged").is_in_hitlag.connect(_on_player_under_hitlag)
	fsm.find_child("PlayerDamaged").is_in_hitstun.connect(_on_player_under_hitstun)
	
func _on_player_moving(direction, delta):
	#print("hello from moving")
	if dir != 0 and is_on_floor():
		prev_dir = dir
	dir = direction
	is_running = true
	#print("direction: " + str(direction))
	#print("dir: " + str(dir))
	#print("prev_dir: " + str(prev_dir))
	var run_force = Vector2(150,0)
	accel = calc_accel(run_force)
	#print("horizontal accel: " + str(accel.x))
	#velocity.x = dir * (speed * delta * 60)
	#if abs(velocity.x) < MAX_SPEED:
		#velocity.x = ((velocity.x + accel.x * dir) * delta * 60)
	##elif abs(velocity.x) <= fr_threshold:
		##velocity.x = 0
	#else:
		#velocity.x = dir * MAX_SPEED * delta * 60
		#accel.x = 0
	#if dir:
		#velocity.x = dir * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		
func _on_player_jumping(type):
	#print("hello from jumping")
	#print(type)
	if type == "high":
		velocity.y = JUMP_VELOCITY
	if type == "short":
		velocity.y = JUMP_VELOCITY*0.65

func _on_player_attacking():
	attack_flag = true

func _physics_process(delta):
	#print("hello from physics process")
	if not is_on_floor():
		is_aerial = true
		velocity.y += gravity * delta
		if velocity.x <= MAX_SPEED:
			pass
		
	if attack_flag and is_on_floor():
		is_running = false
		#velocity.x = lerp(velocity.x, float(0), 0.25)
		#velocity.x = velocity.x * 0.80
		velocity.x = velocity.x - (5 * dir)
		if abs(velocity.x) < 120:
			attack_flag = false
			velocity.x = 0
		#return
	#print(attack_flag)
	#print(velocity.x)
	#if inertia.length() != 0:
		#velocity = velocity + inertia
		#inertia = inertia.lerp(Vector2(0,0), 0.1)
		
	if is_running:
		#velocity = velocity + accel
		if is_on_floor():
			#velocity = (velocity + accel * 10 * dir) * friction * delta
			if abs(velocity.x) < MAX_SPEED * delta:
				velocity = (velocity + accel * 30 * dir * delta * friction)
			else:
				velocity.x = MAX_SPEED * delta * dir * 30
		else:
			#velocity = (velocity + accel * 10 * dir) * air_friction * delta
			if abs(velocity.x) < MAX_SPEED * delta:
				velocity = (velocity + accel * 30 * dir * delta * air_friction)
			else:
				#velocity.x = MAX_SPEED * delta * dir * 30
				velocity.x = move_toward(velocity.x, 0, 0.25)
		if abs(velocity.x) == 0:
			#velocity.x = 0
			is_running = false
	#is_running = false
	else:
		#velocity = velocity.lerp(Vector2(0,0), 0.01)
		#velocity.x = move_toward(velocity.x, 0, 0.1)
		velocity.x = velocity.x - (5 * dir) * delta
		accel = accel.lerp(Vector2(0,0), 0.1)
		print("horizontal accel: " + str(accel.x))
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
	
