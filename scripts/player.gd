extends CharacterBody2D


#const SPEED = 200.0
@export var speed: float = 200.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# reset horizontal orientation
	animated_sprite.flip_h = false
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump_test") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Gets the input direction: -1, 0, or 1
	var direction = Input.get_axis("run_left_test", "run_right_test")
	
	# flip the sprite
	#if direction > 0:
		#animated_sprite.flip_h = false
	#elif direction < 0:
		#animated_sprite.flip_h = true
		
	# play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			if direction > 0:
				animated_sprite.play("walk_right")
			elif direction < 0:
				animated_sprite.play("walk_left")
	else:
		if direction > 0:
			animated_sprite.flip_h = false
			animated_sprite.play("in_air")
		else:
			animated_sprite.flip_h = true
			animated_sprite.play("in_air")
		
	if direction:
		#velocity.x = direction * SPEED
		velocity.x = direction * speed
	else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
