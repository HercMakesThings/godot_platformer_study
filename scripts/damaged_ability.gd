class_name DamagedAbility extends Ability

@export var health_manager: HealthManager
@export var body: CharacterBody2D

var is_hit: bool
var stun_frames: int

var hitbox: HitboxNew

func _ready() -> void:
	health_manager.hit.connect(_on_hit)
	#body.health_manager.hit.connect(_on_hit)
	is_hit = false
	stun_frames = 0
	hitbox = null
	
#func tick_ability(_input: InputGameComponent, movement: MovementComponent, delta: float) -> void:
func tick_ability(movement: MovementComponent, delta: float) -> void:
	if is_hit:
		movement.can_move = false
		stun_frames += 1
		if stun_frames <= hitbox.lag:
			movement.velocity = Vector2.ZERO
			movement.gravity = 0.0
		elif stun_frames <= hitbox.lag + hitbox.stun:
			var force: Vector2 = hitbox.angle_vec.normalized()
			var kb: float = FlushyUtils.calc_kb(hitbox, health_manager.percent, movement.weight)
			force = force * kb
			movement.apply_force(force)
			movement.apply_accel(delta)
		else:
			is_hit = false
			stun_frames = 0
			hitbox = null
			movement.can_move = true
	
func _on_hit(area: Area2D):
	is_hit = true
	stun_frames = 0
	hitbox = area
