class_name JabAbility extends Ability

@export var body: CharacterBody2D
@export var input: Node
@export var hitbox: HitboxNew

@export_range(0, 360, 1) var angle: float = 0.0
@export_range(0, 500, 1) var bkb: float = 0.0
@export_range(0, 500, 1) var kbg: float = 0.0
@export_range(-100, 100, 1) var xoff: float = 0
@export_range(-100, 100, 1) var yoff: float = 0

var active_window: int = 8
var active_window_start: int = 6
var ability_length: int = 18

var atk_initiated: bool
var frames: int
var active_frames: int

func _ready() -> void:
	atk_initiated = false
	frames = 0
	active_frames = 0
	hitbox.angle = angle
	hitbox.bkb = bkb
	hitbox.kbg = kbg
	hitbox.xoff = xoff
	hitbox.yoff = yoff

#func tick_ability(input: InputGameComponent, movement: MovementComponent, delta: float) -> void:
func tick_ability(movement: MovementComponent, delta: float) -> void:
	#print("orientation: " + str(movement.orientation))
	hitbox.orientation = movement.orientation
	#hitbox.position = body.to_global(Vector2((xoff*movement.orientation), yoff))
	#hitbox.position = body.to_global(Vector2((xoff*movement.orientation), yoff))
	#hitbox.position = Vector2(body.position.x+(xoff*movement.orientation), body.position.y+yoff)
	#hitbox.position = body.to_global(body.to_local(Vector2.ZERO))
	if (input.btn_1_input &&
		movement.can_move &&
		movement.current_state != movement.MoveState.AIRBORNE &&
		movement.current_state != movement.MoveState.RUNTURN &&
		body.is_on_floor() &&
		movement.direction.x < movement.deadzone):
			atk_initiated = true
			frames = 0
			movement.can_move = false
			
	if atk_initiated:
		frames += 1
		if body.velocity.length() > 1.0:
			movement.decelerate(delta)
		if frames >= active_window_start && frames < active_window_start + active_window:
			hitbox.is_active = true
		else:
			hitbox.is_active = false
		if frames >= ability_length:
			atk_initiated = false
			frames = 0
			movement.can_move = true
	hitbox.tick(delta)
	
