class_name Player
extends CharacterBody2D

#const SPEED = 200.0
@export var speed: float = 200.0
const MAX_SPEED: float = 200.0
const JUMP_VELOCITY = -300.0
@onready var fsm = $FSM
var dir: int = 1
var prev_dir: int
var accel: Vector2
var mass: float = 5.0
var attack_flag: bool = false
var fr_force = Vector2(0,0)
var fr_threshold = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	prev_dir = dir
	
	fsm.find_child("PlayerMove").is_player_moving.connect(_on_player_moving)
	fsm.find_child("PlayerJumpSquat").is_player_jumping.connect(_on_player_jumping)
	fsm.find_child("PlayerBasicAttack").is_player_attacking.connect(_on_player_attacking)
	
func _on_player_moving(direction, delta):
	if dir != 0 and is_on_floor():
		prev_dir = dir
	dir = direction
	#print("direction: " + str(direction))
	#print("dir: " + str(dir))
	#print("prev_dir: " + str(prev_dir))
	var run_force = Vector2(150,0)
	accel = calc_accel(run_force)
	#velocity.x = dir * (speed * delta * 60)
	if abs(velocity.x) < MAX_SPEED:
		velocity.x = ((velocity.x + accel.x * dir) * delta * 60)
	#elif abs(velocity.x) <= fr_threshold:
		#velocity.x = 0
	else:
		velocity.x = dir * MAX_SPEED * delta * 60
		accel.x = 0
	#if dir:
		#velocity.x = dir * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		
func _on_player_jumping(type):
	#print(type)
	if type == "high":
		velocity.y = JUMP_VELOCITY
	if type == "short":
		velocity.y = JUMP_VELOCITY*0.65

func _on_player_attacking():
	attack_flag = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if attack_flag and is_on_floor():
		#velocity.x = lerp(velocity.x, float(0), 0.25)
		#velocity.x = velocity.x * 0.80
		velocity.x = velocity.x - (5 * dir)
		if abs(velocity.x) < 120:
			attack_flag = false
			velocity.x = 0
	#print(attack_flag)
	#print(velocity.x)
	
	move_and_slide()
	
func calc_accel(force: Vector2) -> Vector2:
	return force / mass
