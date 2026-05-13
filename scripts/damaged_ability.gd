class_name DamagedAbilityOld extends Ability

@export var health_manager: HealthManagerNode
@export var body: CharacterBody2D

@export var hitstun_gravity: float = 4.0

var is_hit: bool
var stun_frames: int

var hitbox: Hitbox

var atk_bkb: float = 0
var atk_kbg: float = 0
var atk_angle: float = 0
var atk_angle_vec: Vector2 = Vector2.ZERO
var atk_dmg: float = 0
var atk_lag: int = 0
var atk_stun: int = 0

func _ready() -> void:
	health_manager.hit.connect(_on_hit)
	#body.health_manager.hit.connect(_on_hit)
	is_hit = false
	stun_frames = 0
	hitbox = null
	
#func tick_ability(_input: InputGameComponent, movement: MovementComponent, delta: float) -> void:
func tick_ability(entity: Entity, delta: float) -> void:
	if is_hit:
		
		#print("is hit true: " + str(is_hit) + ", stun frames: " + str(stun_frames))
		entity.can_move = false
		entity.gravity = hitstun_gravity
		stun_frames += 1
		#if stun_frames <= hitbox.lag:
		if stun_frames <= atk_lag:
			body.velocity = Vector2.ZERO
			#movement.gravity = 0.0
		#elif stun_frames <= hitbox.lag + hitbox.stun:
		elif stun_frames <= atk_lag + atk_stun:
			#var force: Vector2 = hitbox.angle_vec.normalized()
			var force: Vector2 = atk_angle_vec.normalized()
			#var kb: float = FlushyUtils.calc_kb(hitbox, health_manager.percent, movement.weight)
			#var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, health_manager.percent, movement.weight)
			var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, health_manager.percent, entity.get_weight())
			force = force * kb
			print("knockback: " + str(kb))
			#movement.apply_force(force)
			#movement.apply_accel(delta)
			body.velocity = force
			#movement.apply_force(force, delta)
			print("body velocity: " + str(body.velocity))
		else:
			is_hit = false
			stun_frames = 0
			hitbox = null
			atk_angle = 0
			atk_angle_vec = Vector2.ZERO
			atk_dmg = 0
			atk_bkb = 0
			atk_kbg = 0
			atk_stun = 0
			atk_lag = 0
			entity.gravity = entity.GRAVITY
			entity.can_move = true
	
func _on_hit(area: Area2D):
	print("hit!")
	is_hit = true
	stun_frames = 0
	#hitbox = area
	atk_angle = area.stats.angle
	atk_angle_vec = area.angle_vec
	atk_dmg = area.stats.dmg
	atk_bkb = area.stats.bkb
	atk_kbg = area.stats.kbg
	atk_stun = area.stats.stun
	atk_lag = area.stats.lag
	#if hitbox != null:
		#hitbox.bkb = area.bkb
		#hitbox.kbg = area.kbg
		#hitbox.angle = area.angle
		#hitbox.dmg = area.dmg
	#print("area kb lag: " + str(hitbox.lag))
	#print("area kb stun: " + str(hitbox.stun))
