extends RigidBody2D

@onready var movement_component: MovementComponent = %MovementComponent

@export var STARTING_VEL: Vector2 = Vector2.ZERO

var vel: Vector2 = Vector2.ZERO

#@export var custom_dir: Vector2 = Vector2.ZERO:
	#set(value):
		#custom_dir = value.normalized()
@export var custom_dir: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	# apply gravity
	#position.y += 50 * delta
	
	#for body in get_colliding_bodies():
		#print(body)
	#if movement_component.is_on_ground():
		#print("on ground!")
	#else:
		#print("in air!")
		
	vel = movement_component.compute_vel(delta, custom_dir)
	if abs(custom_dir.x) > 0.0 && movement_component.is_on_ground():
	#if abs(custom_dir.x) > 0.0:
		custom_dir.x = move_toward(custom_dir.x, 0, movement_component.calc_friction() * delta)
		#custom_dir.x = move_toward(custom_dir.x, 0, delta)
	#print(custom_dir)
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if STARTING_VEL != Vector2.ZERO:
		#state.linear_velocity += STARTING_VEL
		#STARTING_VEL = Vector2.ZERO
	#state.linear_velocity.y = 50
	state.linear_velocity = vel
