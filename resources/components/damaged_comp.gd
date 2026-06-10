class_name DamagedComponent extends BaseComponent

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

var last_hitbox_rid: RID

func bind(node: Object) -> void:
	super.bind(node)
	#actor.status.hurtbox_hit.connect(_on_attacked)
	if actor.hurtbox is Hurtbox:
		actor.hurtbox.hurtbox_was_hit.connect(_on_attacked)
	is_hit = false
	stun_frames = 0
	last_hitbox_rid = RID()
	
func update(_delta) -> void:
	if is_hit:
		if stun_frames == 0:
			actor.status.update_percent(atk_dmg)
			print("percent: " + str(actor.status.percent))
		actor.entity.can_move = false
		actor.entity.gravity = hitstun_gravity
		stun_frames += 1
		if stun_frames <= atk_lag:
			#actor.entity.body_vel = Vector2.ZERO
			actor.entity.move_paused = true
		elif stun_frames <= atk_lag + atk_stun:
			last_hitbox_rid = RID()
			actor.entity.move_paused = false
			var force: Vector2 = atk_angle_vec.normalized()
			var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, actor.status.percent, actor.entity.get_weight())
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
	
func _on_attacked(area: Area2D, area_rid: RID, area_shape_index: int):
	if last_hitbox_rid != area_rid:
		is_hit = true
		stun_frames = 0
		last_hitbox_rid = area_rid
		print("attacked!")
		atk_angle = area.stats_array[area_shape_index].angle
		atk_angle_vec = area.stats_array[area_shape_index].angle_vec
		atk_dmg = area.stats_array[area_shape_index].dmg
		atk_bkb = area.stats_array[area_shape_index].bkb
		atk_kbg = area.stats_array[area_shape_index].kbg
		atk_stun = area.stats_array[area_shape_index].stun
		atk_lag = area.stats_array[area_shape_index].lag
