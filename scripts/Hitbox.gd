extends Area2D

@onready var player = $".."

var dmg: float = 15
var kb_angle: Vector2 = Vector2(1,2).normalized()
var is_active: bool
var atk_frames;
@onready var shape = $CollisionShape2D
@onready var animated_sprite = $"../AnimatedSprite2D"

var xoff = 18
# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready from hitbox!")
	shape.set_disabled(true)
	is_active = false
	atk_frames = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if player.dir != 0:
		#position.x = position.x * player.dir * 60 * delta
	#else:
		#position.x = position.x * player.prev_dir * 60 * delta

func _physics_process(delta):
	#pass
	#print("player direction: " + str(player.dir))
	#print("x position: " + str(position.x))
	print(animated_sprite.animation)
	is_active = false
	var frame = animated_sprite.get_frame()
	print(frame)
	if animated_sprite.animation == "basic_attack_1":
		if atk_frames >= 10 && atk_frames <= 15:
			is_active = true
		atk_frames += 1
	if atk_frames >= 16:
		atk_frames = 0
	if is_active:
		shape.set_disabled(false)
	else:
		shape.set_disabled(true)
	if player.dir != 0:
		#position.x = (position.x * player.dir) * delta
		#if player.dir == 1:
			#position.x = position.x - (position.x * 2 * player.dir)
		if player.dir == 1:
			#rotation = 0
			#set_rotation(PI/2)
			set_rotation(-0.5585)
		else:
			#rotation = 90
			#set_rotation(0)
			set_rotation(0.5585)
		position.x = xoff * player.dir
	else:
		#position.x = (position.x * player.prev_dir) * delta
		#position.x = position.x - (position.x * 2 * player.prev_dir)
		position.x = xoff * player.prev_dir

func _on_body_entered(body):
	#print("ping!")
	pass
