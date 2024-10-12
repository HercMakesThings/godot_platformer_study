class_name Player
extends CharacterBody2D

#const SPEED = 200.0
@export var speed: float = 200.0
const MAX_SPEED: float = 400.0
const JUMP_VELOCITY = -2000.0
const TERMINAL_VELOCITY = 350.0
@onready var fsm = $FSM
var x_dir_raw: float = 1.0
var prev_dir_x_raw: float
#var dir: int
#var prev_dir: int
var player_dir: int
var dir: Vector2
var prev_dir: Vector2
var accel: Vector2
var air_accel: Vector2
var mass: float = 5.0
var attack_flag: bool = false
var fr_force = Vector2(0,0)
var fr_threshold = 20
var friction = 0.45
var air_friction = 0.95
var air_drift: Vector2
var inertia: Vector2
var is_running: bool
var is_aerial: bool
var weight: float
var on_ground: bool
var extra_jump: int
var air_dodge: int

var dodge_buffer: float
var atk_buffer: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var GRAVITY: int = 20
var gravity

@onready var animated_sprite = $AnimatedSprite2D
@onready var flash_timer = $AnimatedSprite2D/flash_timer

#@onready var hitbox = $Hitbox
@onready var hitbox = $Hitboxes/Jab1Hitbox
@onready var hurtbox = $Hurtbox

@onready var contact_point = $RayCast2D

func _ready():
	gravity = GRAVITY
	prev_dir_x_raw = x_dir_raw
	inertia = Vector2(0,0)
	air_drift = Vector2(0,0)
	weight = gravity * mass
	extra_jump = 1
	air_dodge = 1
	dodge_buffer = 0.0
	atk_buffer = 0.0
	
	fsm.find_child("PlayerMove").is_player_moving.connect(_on_player_moving)
	fsm.find_child("PlayerMove").is_player_air_jumping.connect(_on_player_air_jumping)
	fsm.find_child("PlayerMove").is_player_fast_falling.connect(_on_player_fast_falling)
	fsm.find_child("PlayerCrouch").is_player_crouching.connect(_on_player_crouching)
	fsm.find_child("PlayerJumpSquat").is_player_jumping.connect(_on_player_jumping)
	#fsm.find_child("PlayerBasicAttack").is_player_attacking.connect(_on_player_attacking)
	fsm.find_child("PlayerAttacks").find_child("PlayerBasicAttack").is_player_attacking.connect(_on_player_jab_1)
	#fsm.find_child("PlayerBasicAttack").is_player_fast_falling.connect(_on_player_fast_falling)
	fsm.find_child("PlayerAttacks").find_child("PlayerBasicAttack").is_player_fast_falling.connect(_on_player_fast_falling)
	fsm.find_child("PlayerAttacks").find_child("PlayerJab2").is_player_attacking.connect(_on_player_jab_2)
	fsm.find_child("PlayerAttacks").find_child("PlayerJab3").is_player_attacking.connect(_on_player_jab_3)
	fsm.find_child("PlayerDamaged").is_in_hitlag.connect(_on_player_under_hitlag)
	fsm.find_child("PlayerDamaged").is_in_hitstun.connect(_on_player_under_hitstun)
	fsm.find_child("PlayerLandingLag").is_in_landing_lag.connect(_on_player_under_landing_lag)
	fsm.find_child("PlayerAirDodge").is_player_airdodging.connect(_on_player_airdodging)
	
func _on_player_moving(direction, delta):
	#hurtbox.find_child("CollisionShape2D").scale.y = 1
	if x_dir_raw != 0 and is_on_floor():
		prev_dir_x_raw = x_dir_raw
	x_dir_raw = direction.x
	if x_dir_raw < 0:
		#dir = floorf(x_dir_raw)
		dir = Vector2(floorf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = floorf(x_dir_raw)
		#prev_dir = floorf(prev_dir_x_raw)
		prev_dir = Vector2(floorf(prev_dir_x_raw), velocity.y)
	elif x_dir_raw > 0:
		#dir = ceilf(x_dir_raw)
		dir = Vector2(ceilf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = ceilf(x_dir_raw)
		#prev_dir = ceilf(prev_dir_x_raw)
		prev_dir = Vector2(ceilf(prev_dir_x_raw), velocity.y)
	#dir = ceilf(x_dir_raw)
	#prev_dir = ceilf(prev_dir_x_raw)
	is_running = true
	#print("direction: " + str(direction))
	#print("x_dir_raw: " + str(x_dir_raw))
	#print("prev_dir_x_raw: " + str(prev_dir_x_raw))
	#print("normalized dir: " + str(dir))
	#print("normalized prev_dir: " + str(prev_dir))
	#print("player_dir: " + str(player_dir))
	var player_input_force = Vector2(150,0)
	apply_force(player_input_force);
	
func _on_player_crouching():
	hurtbox.find_child("CollisionShape2D").scale.y = 0.6
	##hurtbox.find_child("CollisionShape2D").shape.height = 13.01
	hurtbox.find_child("CollisionShape2D").position.y = -5
	pass
	
func _on_player_jumping(type, _delta):
	if type == "high":
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY))
	if type == "short":
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
	if guard_pressed():
		#dodge_buffer = 0.4
		dodge_buffer = 0.06
	#if dodge_buffer > 0.0:
		#dodge_buffer -= _delta
	velocity += air_accel
	
	
func _on_player_air_jumping(j):
	if extra_jump == 1:
		#velocity.y = JUMP_VELOCITY * 0.35
		velocity.y = JUMP_VELOCITY * 0.175
		extra_jump = 0
	
func _on_player_jab_1():
	attack_flag = true
	if Input.is_action_pressed("attack_2_test"):
		atk_buffer = 0.04
	
func _on_player_jab_2():
	#velocity.y -= 50
	#velocity.y = move_toward(velocity.y, -500, 250)
	#if attack_flag == false:
		#velocity.y = JUMP_VELOCITY * 0.175
	velocity.y = JUMP_VELOCITY * 0.08
	if Input.is_action_pressed("attack_3_test"):
		atk_buffer = 0.08
	attack_flag = true
	#pass
	
func _on_player_jab_3():
	attack_flag = true
	
func _on_player_fast_falling():
	air_accel = calc_accel(Vector2(0,JUMP_VELOCITY))
	velocity.y = velocity.y - (air_accel.y * 2)
	
func _on_player_under_landing_lag():
	air_dodge = 1
	velocity = velocity.lerp(Vector2(0,0), 0.1)
	
func _physics_process(delta):
	if str(fsm.current_state) != "PlayerCrouch":
		hurtbox.find_child("CollisionShape2D").scale.y = 1
		##hurtbox.find_child("CollisionShape2D").shape.height = 26.02
		hurtbox.find_child("CollisionShape2D").position.y = -11
	#hitbox.set_process_mode(PROCESS_MODE_DISABLED)
	if not is_on_floor():
		is_aerial = true
		on_ground = false
		if velocity.y < TERMINAL_VELOCITY:
			#velocity.y = velocity.y + 20
			velocity.y += gravity
		else:
			velocity.y = TERMINAL_VELOCITY
		if velocity.x <= MAX_SPEED:
			pass
		if dodge_buffer > 0.0:
			fsm.force_change_state("PlayerAirDodge")
	else:
		if !on_ground:
			if !contact_point.is_colliding():
				fsm.force_change_state("PlayerIdle")
			else:
				fsm.force_change_state("PlayerLandingLag")
		on_ground = true
		if extra_jump == 0:
			extra_jump = 1
		
	#if attack_flag and is_on_floor():
	#if attack_flag:
		##is_running = false
		#if is_on_floor():
			##velocity.x = velocity.x - (5 * x_dir_raw)
			#velocity.x = lerp(velocity.x, 0.0, 0.1)
		#if abs(velocity.x) < 120:
			#attack_flag = false
			#velocity.x = 0
		
	if is_running || attack_flag:
		if is_on_floor():
			if attack_flag:
				velocity.x = lerp(velocity.x, 0.0, 0.1)
			elif abs(velocity.x) < MAX_SPEED * delta:
				velocity = (velocity + accel * 300 * x_dir_raw * delta * friction)
			else:
				velocity.x = MAX_SPEED * delta * x_dir_raw * 30
		else:
			if abs(velocity.x) < (MAX_SPEED*0.5):
				velocity = velocity + ((accel * 5) * dir.x * delta)
				velocity.x = velocity.x * air_friction
			else:
				velocity.x = (MAX_SPEED*0.5)*dir.x
		if abs(velocity.x) == 0:
			is_running = false
			attack_flag = false
	else:
		if on_ground:
			velocity.x = move_toward(velocity.x, 0, 5)
		else:
			#print("in air but not influencing x_dir_raw")
			velocity.x = move_toward(velocity.x, 0, abs(velocity.x*0.05))
		accel = accel.lerp(Vector2(0,0), 1)
		air_accel = air_accel.lerp(Vector2(0,0), 1)
	is_running = false
	#print("player_dir: " + str(player_dir))
	#var flash = animated_sprite.material.get_shader_parameter("flash_modifier")
	#animated_sprite.material.set_shader_parameter("flash_modifier", move_toward(flash, 0.0, 0.1))
	#if dodge_buffer > 0:
		#print("dodge buffer: " + str(dodge_buffer))
	if dodge_buffer > 0.0:
		dodge_buffer -= delta
	if atk_buffer > 0.0:
		atk_buffer -= delta
	move_and_slide()
	
func _on_hurtbox_area_entered(area):
	if area.is_in_group("atk_hitbox_group"):
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
	accel = calc_accel(force*200)
	#if velocity.x < MAX_SPEED*1.5:
		#velocity = (velocity + accel) * delta * 60
		#velocity = (velocity + (accel*20) * 60 * delta)
		#velocity.x = velocity.x - 5
	#elif velocity.x >= MAX_SPEED:
		#velocity.x = move_toward(MAX_SPEED, 0, 1)
		#inertia = accel*20
	velocity = (velocity + (accel) * 60 * delta)
	#inertia = accel*100
	#inertia = accel.from_angle(get_angle_to(accel))*100
	
func _on_player_airdodging(ad_dir, ad_frames, _delta):
	if air_dodge > 0:
		#air_dodge = 0
		if ad_frames == 2:
			flash_timer.start()
			animated_sprite.material.set_shader_parameter("flash_modifier", 0.6)
		if ad_frames < 16:
			#gravity = 0
			#if is_on_floor():
			if on_ground:
				#velocity = ad_dir * 30000 * _delta
				velocity = ad_dir * 2500
				#velocity = ad_dir * 500 * air_friction
				#fsm.force_change_state("PlayerIdle")
				#fsm.force_change_state("PlayerLandingLag")
				if ad_frames > 12:
					dodge_buffer = 0
					air_dodge = 0
					#fsm.force_change_state("PlayerMove")
					fsm.force_change_state("PlayerIdle")
			else:
				#velocity = ad_dir * 20000 * _delta
				velocity = ad_dir * 450
				#velocity = ad_dir * 500 * friction
		elif ad_frames >= 16:
			velocity = lerp(velocity, Vector2(0,0), 0.5)
		#if ad_frames >= 30 || is_on_floor():
		#if ad_frames >= 30 || on_ground:
		if ad_frames >= 30:
			air_dodge = 0
			dodge_buffer = 0.0
			#gravity = GRAVITY
			#pass
	
func _on_flash_timer_timeout():
	animated_sprite.material.set_shader_parameter("flash_modifier", 0.0)
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2):
	accel = accel + calc_accel(force)
	
func guard_pressed():
	#return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
	return Input.is_action_pressed("guard_left") || Input.is_action_pressed("guard_right")
	
