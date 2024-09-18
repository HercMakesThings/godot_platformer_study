extends Area2D
##class_name HitboxBase
#
##@onready var player = $".."
#@onready var player = $"../.."
#
#var dmg: float = 15
#var kb_angle: Vector2 = Vector2(1,2).normalized()
#var is_active: bool
#var atk_frames;
#var count;
##@onready var shape = $HitboxShape
##@onready var collision_shape_2d_2 = $CollisionShape2D2
#@onready var hitbox_shape = $HitboxShape
#
##@onready var animated_sprite = $"../AnimatedSprite2D"
#@onready var animated_sprite = $"../../AnimatedSprite2D"
##@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
#
##@export var xoff: int = 18
#@export var xoff: int = 20
#@export var yoff: int = -10
##@export var xoff: int
##@export var yoff: int
#
#@export var active_window_begin: int = 12
#@export var active_window_end: int = 25
#@export var move_length: int = 31
#@export var rot: float = 0.5585
#@export var move_animation: String = "basic_attack_1"
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	##print("ready from hitbox!")
	#if hitbox_shape:
		#hitbox_shape.set_disabled(true)
	#is_active = false
	#atk_frames = 0
	#count = 0
	#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	#
#func _physics_process(delta):
	#is_active = false
	##if animated_sprite.get_animation() == "basic_attack_1":
	#if animated_sprite.get_animation() == move_animation:
		#var frame = animated_sprite.get_frame()
		##print(frame)
		#if atk_frames >= active_window_begin && atk_frames <= active_window_end:
			#is_active = true
		#atk_frames += 1
	#else:
		#atk_frames = 0
	#if atk_frames >= move_length:
		#atk_frames = 0
	#if is_active:
		#hitbox_shape.set_disabled(false)
	#else:
		#hitbox_shape.set_disabled(true)
	#if player.player_dir > 0:
		##set_rotation(-0.5585)
		#set_rotation(-rot)
	#elif player.player_dir < 0:
		##set_rotation(0.5585)
		#set_rotation(rot)
	##position = player.position
	##position = player.to_global(Vector2(18, -10))
	#if player.player_dir != 0:
		##position.x = xoff * player.player_dir
		##position = to_local(player.position)
		##var new_pos = player.to_global(position)
		##position.x = position.x + (xoff * player.player_dir)
		##position.y = position.y + yoff
		#position = player.to_global(Vector2((xoff*player.player_dir), yoff))
		##position.x = position.x * player.player_dir
		##position = new_pos
		##position = player.to_local() 
		##player.position.up_direction
		##player.position.unit
	#else:
		##position.x = xoff
		##position.x += xoff
		##position.y += yoff
		##position = player.to_global(Vector2(18, -10))
		#position = player.to_global(Vector2(xoff, yoff))
	#
##func _on_body_entered(body):
	##print("Attack!")
	##pass
