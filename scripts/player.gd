class_name Player
extends CharacterBody2D

@export var MAX_SPEED: float = 400.0
@export var JUMP_VELOCITY = -2000.0
@export var TERMINAL_VELOCITY = 350.0
@onready var fsm = $FSM
var x_dir_raw: float = 1.0
var prev_dir_x_raw: float
#var dir: int
#var prev_dir: int
var player_dir: int
var dir: Vector2
var prev_dir: Vector2
var player_orientation: int
var accel: Vector2
var air_accel: Vector2
var mass: float = 5.0
var attack_flag: bool = false
var fr_force = Vector2(0,0)
var fr_threshold = 20
@export_range(0.0, 1, 0.05) var friction := 0.45
@export_range(0.0, 1, 0.05) var air_friction := 0.95
var air_drift: Vector2
var inertia: Vector2
var is_moving: bool
var is_dashing: bool
var is_aerial: bool
var weight: float
var on_ground: bool
var extra_jump: int
var air_dodge: int

var dodge_buffer: float
var atk_buffer: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
#@export var GRAVITY: float = 20
var gravity: float

@onready var animated_sprite = $AnimatedSprite2D
@onready var flash_timer = $AnimatedSprite2D/flash_timer

#@onready var hitbox = $Hitbox
#@onready var hitbox = $Hitboxes/Jab1Hitbox
@onready var hurtbox = $Hurtbox
#@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var ecb: CollisionShape2D = $EnvironmentCollisionBox

@onready var HealthManager = $HealthManager
@onready var StaminaManager = $StaminaManager


@onready var contact_point = $FloorContactRay
@onready var orientation_arrow = $OrientationVis

@onready var platform_manager: PlatformManager = $"../PlatformManager"

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
	player_orientation = 1
	
	hurtbox.hurtbox_hit.connect(_on_hurtbox_area_entered)
	
	fsm.find_child("PlayerIdle").is_idle.connect(_on_player_idle)
	fsm.find_child("PlayerMove").is_player_moving.connect(_on_player_moving)
	fsm.find_child("PlayerMove").is_player_air_jumping.connect(_on_player_air_jumping)
	fsm.find_child("PlayerMove").is_player_fast_falling.connect(_on_player_fast_falling)
	fsm.find_child("PlayerCrouch").is_player_crouching.connect(_on_player_crouching)
	fsm.find_child("PlayerJumpSquat").is_player_jumping.connect(_on_player_jumping)
	fsm.find_child("PlayerInAir").is_player_in_air.connect(_on_player_airborne)
	fsm.find_child("PlayerWalk").is_player_walking.connect(_on_player_walking)
	fsm.find_child("PlayerDash").is_player_dashing.connect(_on_player_dashing)
	fsm.find_child("PlayerRun").is_player_running.connect(_on_player_running)
	fsm.find_child("PlayerRunSkid").is_player_skidding.connect(_on_player_skidding)
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
	
	platform_manager._pl_on_platform.connect(_on_player_on_platform)
	
func _on_player_idle():
	if player_orientation == 0:
		animated_sprite.flip_h = true
		#animated_sprite.flip_h = false
	elif player_orientation == 1:
		animated_sprite.flip_h = false
		#animated_sprite.flip_h = true
	animated_sprite.play("idle")
	pass
	
func _on_player_moving(direction, delta):
	if x_dir_raw != 0.0 and is_on_floor():
		prev_dir_x_raw = x_dir_raw
	x_dir_raw = direction.x
	if x_dir_raw < 0.0:
		dir = Vector2(floorf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = floorf(x_dir_raw)
			player_orientation = 0
		prev_dir = Vector2(floorf(prev_dir_x_raw), velocity.y)
	elif x_dir_raw > 0.0:
		dir = Vector2(ceilf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = ceilf(x_dir_raw)
			player_orientation = 1
		prev_dir = Vector2(ceilf(prev_dir_x_raw), velocity.y)
	is_moving = true
	var player_input_force = Vector2(150,0)
	apply_force(player_input_force);
	if is_on_floor():
		if player_orientation == 0:
			animated_sprite.flip_h = false
			animated_sprite.play("walk_left")
		elif player_orientation == 1:
			animated_sprite.flip_h = false
			animated_sprite.play("walk_right")
	else:
		if player_orientation == 0:
			animated_sprite.flip_h = true
			animated_sprite.play("in_air")
		elif player_orientation == 1:
			animated_sprite.flip_h = false
			animated_sprite.play("in_air")
	
func _on_player_crouching():
	hurtbox.find_child("CollisionShape2D").scale.y = 0.6
	hurtbox.find_child("CollisionShape2D").position.y = -5
	animated_sprite.play("crouch")
	
func _on_player_on_platform(platform, collider):
	#print("platform name: " + platform.name, ", collider: " + collider.name)
	if fsm.current_state.name == "PlayerCrouch" && platform is PlatformBasic:
		ecb.disabled = true
		return
	if ecb.disabled:
		ecb.disabled = false
	
func _on_player_jumping(type, _delta):
	if type == "high":
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY))
	if type == "short":
		air_accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
	if guard_pressed():
		dodge_buffer = 0.4
		#dodge_buffer = 0.06
	#if dodge_buffer > 0.0:
		#dodge_buffer -= _delta
	velocity += air_accel
	
func _on_player_airborne():
	pass
	
func _on_player_walking():
	pass
	
func _on_player_dashing(direction: Vector2, _delta: float):
	if x_dir_raw != 0.0 and is_on_floor():
		prev_dir_x_raw = x_dir_raw
	x_dir_raw = direction.x
	is_dashing = true
	is_moving = true
	if x_dir_raw < 0.0:
		dir = Vector2(floorf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = floorf(x_dir_raw)
			player_orientation = 0
		prev_dir = Vector2(floorf(prev_dir_x_raw), velocity.y)
	elif x_dir_raw > 0.0:
		dir = Vector2(ceilf(x_dir_raw), velocity.y)
		if is_on_floor():
			player_dir = ceilf(x_dir_raw)
			player_orientation = 1
		prev_dir = Vector2(ceilf(prev_dir_x_raw), velocity.y)
	var player_input_force = Vector2(250,0)
	apply_force(player_input_force);
	if is_on_floor():
		if player_orientation == 0:
			animated_sprite.flip_h = false
			animated_sprite.play("walk_left")
		elif player_orientation == 1:
			animated_sprite.flip_h = false
			animated_sprite.play("walk_right")
	else:
		if player_orientation == 0:
			animated_sprite.flip_h = true
			animated_sprite.play("in_air")
		elif player_orientation == 1:
			animated_sprite.flip_h = false
			animated_sprite.play("in_air")
	pass
	
func _on_player_running():
	pass
	
func _on_player_skidding():
	pass
	
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
	velocity.y = velocity.y - (air_accel.y * 1.5)
	
func _on_player_under_landing_lag():
	air_dodge = 1
	velocity = velocity.lerp(Vector2(0,0), 0.1)
	#if player_orientation == 0:
		#animated_sprite.flip_h = true
	#elif player_orientation == 1:
		#animated_sprite.flip_h = false
	
#func _input(event: InputEvent) -> void:
	#pass
	
func _physics_process(delta):
	if contact_point.is_colliding():
		var collider = contact_point.get_collider()
		if collider.name == "groundLayer" && ecb.disabled:
			ecb.disabled = false
	if str(fsm.current_state) != "PlayerCrouch":
		hurtbox.find_child("CollisionShape2D").scale.y = 1
		hurtbox.find_child("CollisionShape2D").position.y = -11
			
	if is_on_floor():
		if !on_ground:
			if !contact_point.is_colliding():
				fsm.force_change_state("PlayerIdle")
			else:
				fsm.force_change_state("PlayerLandingLag")
		on_ground = true
		if extra_jump == 0:
			extra_jump = 1
	else:
		is_aerial = true
		on_ground = false
	apply_gravity()
		
	#match str(fsm.current_state):
	match fsm.current_state.name:
		"PlayerIdle":
			print("idle state")
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, 5)
			accel = accel.lerp(Vector2(0,0), 1)
			air_accel = air_accel.lerp(Vector2(0,0), 1)
		"PlayerMove":
			print("Move state")
			if is_on_floor():
				if abs(velocity.x) < MAX_SPEED:
					if prev_dir.x != dir.x:
						accel = Vector2(0, 0)
					#velocity = (velocity + accel * 300 * x_dir_raw * friction * delta)
					velocity = (velocity + accel * x_dir_raw * friction * delta)
				else:
					#velocity.x = MAX_SPEED * x_dir_raw * 30
					velocity.x = abs(MAX_SPEED) * dir.x
			else:
				if abs(velocity.x) < (MAX_SPEED*0.5):
					velocity = velocity + ((accel * 5) * dir.x * delta)
					velocity.x = velocity.x * air_friction
				else:
					velocity.x = (MAX_SPEED*0.5)*dir.x
				velocity.x = move_toward(velocity.x, 0, abs(velocity.x*0.05))
		"PlayerDash":
			print("Dash State")
			if is_on_floor():
				#if abs(velocity.x) < MAX_SPEED * delta:
				if abs(velocity.x) < MAX_SPEED:
					if prev_dir.x != dir.x:
						accel = Vector2(0, 0)
					#velocity = (velocity + accel * 300 * x_dir_raw * delta * friction)
					#velocity = (velocity + accel * 300 * x_dir_raw * friction * delta)
					velocity = (velocity + accel * x_dir_raw * friction * delta)
				else:
					#velocity.x = MAX_SPEED * delta * x_dir_raw * 30
					#velocity.x = MAX_SPEED * x_dir_raw * 30
					velocity.x = abs(MAX_SPEED) * dir.x
			else:
				if abs(velocity.x) < (MAX_SPEED*0.5):
					velocity = velocity + ((accel * 5) * dir.x * delta)
					velocity.x = velocity.x * air_friction
				else:
					velocity.x = abs(MAX_SPEED*0.5)*dir.x
			if abs(velocity.x) == 0:
				is_moving = false
				is_dashing = false
				attack_flag = false
		"PlayerInAir":
			print("InAir state")
		"PlayerJumpSquat":
			print("JumpSquat state")
		"PlayerDamaged":
			print("Damaged state")
		"PlayerLandingLag":
			print("LandingLag state")
		"PlayerCrouch":
			print("Crouch state")
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, 2)
		"PlayerAirDodge":
			print("AirDodge state")
		"PlayerBasic":
			print("Basic state")
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		"PlayerJab2":
			print("Jab2 state")
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		"PlayerJab3":
			print("Jab3 state")
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		"PlayerShield":
			print("Shield state")
		"PlayerRun":
			print("Run state")
		"PlayerWalk":
			print("Walk state")
		"PlayerRunSkid":
			print("RunSkid state")
		
	#accel = accel.lerp(Vector2(0,0), 1)
	#air_accel = air_accel.lerp(Vector2(0,0), 1)
		
	#if is_moving || attack_flag:
		#if is_dashing:
			#if is_on_floor():
				#if attack_flag:
					#velocity.x = lerp(velocity.x, 0.0, 0.1)
				#elif abs(velocity.x) < MAX_SPEED * delta:
					#if prev_dir.x != dir.x:
						#accel = Vector2(0, 0)
					#velocity = (velocity + accel * 300 * x_dir_raw * delta * friction)
				#else:
					#velocity.x = MAX_SPEED * delta * x_dir_raw * 30
			#else:
				#if abs(velocity.x) < (MAX_SPEED*0.5):
					#velocity = velocity + ((accel * 5) * dir.x * delta)
					#velocity.x = velocity.x * air_friction
				#else:
					#velocity.x = (MAX_SPEED*0.5)*dir.x
			#if abs(velocity.x) == 0:
				#is_moving = false
				#is_dashing = false
				#attack_flag = false
		#else:
			#if is_on_floor():
				#if attack_flag:
					#velocity.x = lerp(velocity.x, 0.0, 0.1)
				#elif abs(velocity.x) < MAX_SPEED * delta:
					#if prev_dir.x != dir.x:
						#accel = Vector2(0, 0)
					#velocity = (velocity + accel * 300 * x_dir_raw * delta * friction)
				#else:
					#velocity.x = MAX_SPEED * delta * x_dir_raw * 30
			#else:
				#if abs(velocity.x) < (MAX_SPEED*0.5):
					#velocity = velocity + ((accel * 5) * dir.x * delta)
					#velocity.x = velocity.x * air_friction
				#else:
					#velocity.x = (MAX_SPEED*0.5)*dir.x
			#if abs(velocity.x) == 0:
				#is_moving = false
				#is_dashing = false
				#attack_flag = false
	#else:
		#if on_ground:
			#if fsm.current_state.name == "PlayerCrouch":
				#velocity.x = move_toward(velocity.x, 0, 2)
			#else:
				#velocity.x = move_toward(velocity.x, 0, 5)
		#else:
			##print("in air but not influencing x_dir_raw")
			#velocity.x = move_toward(velocity.x, 0, abs(velocity.x*0.05))
		#accel = accel.lerp(Vector2(0,0), 1)
		#air_accel = air_accel.lerp(Vector2(0,0), 1)
	is_moving = false
	is_dashing = false
	#print("player_dir: " + str(player_dir))
	#var flash = animated_sprite.material.get_shader_parameter("flash_modifier")
	#animated_sprite.material.set_shader_parameter("flash_modifier", move_toward(flash, 0.0, 0.1))
	#if dodge_buffer > 0:
		#print("dodge buffer: " + str(dodge_buffer))
	if dodge_buffer > 0.0:
		dodge_buffer -= delta
	if atk_buffer > 0.0:
		atk_buffer -= delta
	#print("player_orientation: " + str(player_orientation))
	move_and_slide()
	
func _on_hurtbox_area_entered(area):
	if area.is_in_group("atk_hitbox_group") and area is HitboxOld:
		#print(area.name)
		fsm.force_change_state("PlayerDamaged", area)
		return
		
func _on_player_under_hitlag(delta):
	velocity.x = 0
	velocity.y = 0
	#velocity += (Vector2(randf(), randf()).normalized() * 300)
	gravity = 0
	
func _on_player_under_hitstun(delta, area):
	#inertia = accel.from_angle(get_angle_to(accel))*100
	#print("hitbox dmg: " + str(area.dmg))
	#print("hitbox kb angle: " + str(area.angle))
	if gravity == 0:
		gravity = GRAVITY
	var angle = deg_to_rad(area.angle)
	#var force = Vector2(1,0).rotated(angle).normalized()
	var force = area.angle_vec.normalized()
	var dmg = area.dmg
	var bkb = area.bkb
	var kbg = area.kbg / 100.0
	#var kbg = area.kbg
	var p = HealthManager.percent
	#var kb = ((p + (dmg*p) + bkb)*kbg) / (weight * 1)
	#var kb = ((((p + (dmg*p))*(50/(weight+10)))*kbg)+bkb)
	var kb = FlushyUtils.calc_kb(area, p, weight)
	force = force * kb
	#accel = calc_accel(force*200)
	accel = calc_accel(force)
	#accel = calc_accel(f)
	#velocity = (velocity + (accel) * 60 * delta)
	velocity = velocity + accel + Vector2(0, gravity*0.25)
	
	
func _on_player_airdodging(ad_dir: Vector2, ad_frames, _delta):
	if air_dodge > 0:
		#air_dodge = 0
		if ad_frames == 1:
			flash_timer.start()
			animated_sprite.material.set_shader_parameter("flash_modifier", 0.6)
		#if ad_frames < 16:
		if ad_frames < 10:
			#gravity = 0
			#if is_on_floor():
			if on_ground:
				#velocity = ad_dir * 30000 * _delta
				#velocity = ad_dir * 2500
				velocity = ad_dir * 500
				#velocity = ad_dir * 500 * air_friction
				#fsm.force_change_state("PlayerIdle")
				#fsm.force_change_state("PlayerLandingLag")
				#if ad_frames > 12:
				if ad_frames > 6:
					dodge_buffer = 0
					#air_dodge = 0
					#fsm.force_change_state("PlayerMove")
					#fsm.force_change_state("PlayerIdle")
			else:
				#velocity = ad_dir * 20000 * _delta
				velocity = ad_dir * 450
				#velocity = ad_dir * 500 * friction
		#elif ad_frames >= 16:
		elif ad_frames >= 10:
			if is_on_floor():
				velocity = lerp(velocity, Vector2(0,0), 0.05)
			#velocity = lerp(velocity, Vector2(0,0), friction)
			else:
				velocity = lerp(velocity, Vector2(0,0), 0.5)
		#if ad_frames >= 30 || is_on_floor():
		#if ad_frames >= 30 || on_ground:
		#if ad_frames >= 30:
		if ad_frames >= 16:
			air_dodge = 0
			dodge_buffer = 0.0
			#gravity = GRAVITY
			#pass
	
func _on_flash_timer_timeout():
	animated_sprite.material.set_shader_parameter("flash_modifier", 0.0)
	
func apply_gravity(extra: float = 0) -> void:
	if velocity.y < TERMINAL_VELOCITY:
		velocity.y += gravity
	else:
		velocity.y = TERMINAL_VELOCITY
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2):
	accel = accel + calc_accel(force)
	
func apply_accel() -> void:
	velocity = (velocity + accel * 300 * x_dir_raw * friction)
	
func calc_nForce() -> float:
	return mass * gravity
	
func calc_friction() -> float:
	var nf = calc_nForce()
	if is_on_floor():
		return nf * friction
	else:
		return nf * air_friction
	
func guard_pressed():
	#return Input.is_action_just_pressed("guard_left") || Input.is_action_just_pressed("guard_right")
	return Input.is_action_pressed("guard_left") || Input.is_action_pressed("guard_right")
	
