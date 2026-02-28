extends Resource
class_name HFEntity

#const MAX_SPEED: float = 400.0
#const JUMP_VELOCITY = -2000.0
#const TERMINAL_VELOCITY = 350.0
@export var MAX_SPEED: float = 400.0
@export var JUMP_VELOCITY = -2000.0
@export var TERMINAL_VELOCITY = 350.0

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
@export var mass: float = 5.0
var attack_flag: bool = false
@export var fr_force = Vector2(0,0)
@export var fr_threshold = 20
@export_range(0.0, 1, 0.05) var friction := 0.45
@export_range(0.0, 1, 0.05) var air_friction := 0.95
@export var air_drift: Vector2
var inertia: Vector2
var is_moving: bool
var is_dashing: bool
var is_aerial: bool
var weight: float
var on_ground: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var GRAVITY: float = 20
var gravity: float

var velocity: Vector2

func _ready():
	gravity = GRAVITY
	prev_dir_x_raw = x_dir_raw
	inertia = Vector2(0,0)
	air_drift = Vector2(0,0)
	weight = gravity * mass
	player_orientation = 1

func calc_accel(force: Vector2) -> Vector2:
	return force / mass
	
func apply_force(force: Vector2):
	accel = accel + calc_accel(force)
	
func apply_gravity():
	is_aerial = true
	on_ground = false
	if velocity.y < TERMINAL_VELOCITY:
		velocity.y += gravity
	else:
		velocity.y = TERMINAL_VELOCITY
