extends Area2D

#@onready var player = $".."
@onready var player = $"../.."

var dmg: float = 15
var kb_angle: Vector2 = Vector2(1,2).normalized()
var is_active: bool
var atk_frames;
var count;
var is_colliding: bool
#@onready var shape = $CollisionShape2D2
@onready var shape: CollisionShape2D = $hitbox_shape
#@onready var collision_shape_2d_2 = $CollisionShape2D2

#@onready var animated_sprite = $"../AnimatedSprite2D"
@onready var animated_sprite = $"../../AnimatedSprite2D"

#@export var xoff: int = 18
@export var xoff: int = 20
@export var yoff: int = -10
#@export var xoff: int
#@export var yoff: int

@export var active_window_begin: int = 12
@export var active_window_end: int = 25
@export var move_length: int = 31
@export var rot: float = 0.5585
@export var move_animation: String = "basic_attack_1"

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("ready from hitbox!")
	shape.set_disabled(true)
	is_active = false
	is_colliding = false
	atk_frames = 0
	count = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	is_active = false
	match move_animation:
		"basic_attack_1":
			pass
		"basic_attack_2":
			pass
		"basic_attack_3":
			pass
		_:
			pass
	if animated_sprite.get_animation() == move_animation:
		var frame = animated_sprite.get_frame()
		#print(frame)
		if atk_frames >= active_window_begin && atk_frames <= active_window_end:
			is_active = true
		atk_frames += 1
	else:
		atk_frames = 0
	if atk_frames >= move_length:
		atk_frames = 0
	if is_active:
		shape.set_disabled(false)
	else:
		shape.set_disabled(true)
	if player.player_dir > 0:
		set_rotation(-rot)
	elif player.player_dir < 0:
		set_rotation(rot)
	if player.player_dir != 0:
		position = player.to_global(Vector2((xoff*player.player_dir), yoff))
		#player.position.up_direction
		#player.position.unit
	else:
		position = player.to_global(Vector2(xoff, yoff))
	#if is_active && is_colliding:
		#print("hit!")
	
func _on_body_entered(body):
	#if shape.is_disabled() == false:
	is_colliding = true
	#print(move_animation + " Attack!")
	
func _on_body_exited(body):
	is_colliding = false
