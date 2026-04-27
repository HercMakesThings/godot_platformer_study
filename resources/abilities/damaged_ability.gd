class_name DamagedAbility extends AbilityRes

var name: String = "DamagedAbility"

@export var hitstun_gravity: float = 4.0

var is_hit: bool
var stun_frames: int

var atk_bkb: float = 0
var atk_kbg: float = 0
var atk_angle: float = 0
var atk_angle_vec: Vector2 = Vector2.ZERO
var atk_dmg: float = 0
var atk_lag: int = 0
var atk_stun: int = 0

func _init_ability(actor: CharacterBody2D) -> void:
	actor.health_manager.hit.connect(_on_hit)
	is_hit = false
	stun_frames = 0
	
func _act(actor: CharacterBody2D, _delta: float) -> void:
	if is_hit:
		#print("is hit true: " + str(is_hit) + ", stun frames: " + str(stun_frames))
		actor.entity.can_move = false
		actor.entity.gravity = hitstun_gravity
		stun_frames += 1
		if stun_frames <= atk_lag:
			actor.entity.body_vel = Vector2.ZERO
		elif stun_frames <= atk_lag + atk_stun:
			#var force: Vector2 = hitbox.angle_vec.normalized()
			var force: Vector2 = atk_angle_vec.normalized()
			#var kb: float = FlushyUtils.calc_kb(hitbox, health_manager.percent, entity.weight)
			#var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, health_manager.percent, entity.weight)
			var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, actor.health_manager.percent, actor.entity.get_weight())
			force = force * kb
			#print("knockback: " + str(kb))
			#body.velocity = force
			actor.entity.body_vel = force
			#entity.apply_force(force, delta)
		else:
			is_hit = false
			stun_frames = 0
			atk_angle = 0
			atk_angle_vec = Vector2.ZERO
			atk_dmg = 0
			atk_bkb = 0
			atk_kbg = 0
			atk_stun = 0
			atk_lag = 0
			actor.entity.gravity = actor.entity.GRAVITY
			actor.entity.can_move = true

func _on_hit(area: Area2D):
	print("hit!")
	is_hit = true
	stun_frames = 0
	
	#atk_angle = area.angle
	#atk_angle_vec = area.angle_vec
	#atk_dmg = area.dmg
	#atk_bkb = area.bkb
	#atk_kbg = area.kbg
	#atk_stun = area.stun
	#atk_lag = area.lag
	
	atk_angle = area.stats.angle
	atk_angle_vec = area.angle_vec
	atk_dmg = area.stats.dmg
	atk_bkb = area.stats.bkb
	atk_kbg = area.stats.kbg
	atk_stun = area.stats.stun
	atk_lag = area.stats.lag
