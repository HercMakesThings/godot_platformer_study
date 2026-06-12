class_name KnockbackEffect extends OnHitEffect

@export var hitstun_gravity: float = 4.0

var stun_frames: int = 0

func _execute(owner: Object, area: Area2D, _area_rid: RID, area_shape_index: int) -> void:
	if owner is not Article:
		return
	if area is not Hitbox:
		return
	owner.entity.can_move = false
	owner.entity.gravity = hitstun_gravity
	var atk_angle_vec: Vector2 = area.stats_array[area_shape_index].angle_vec
	var atk_dmg: float = area.stats_array[area_shape_index].dmg
	var atk_bkb: float = area.stats_array[area_shape_index].bkb
	var atk_kbg: float = area.stats_array[area_shape_index].kbg
	owner.status.update_percent(atk_dmg)
	print("percent: " + str(owner.status.percent))
	var atk_lag: float = area.stats_array[area_shape_index].lag
	var atk_stun: float = area.stats_array[area_shape_index].stun
	for i in range(atk_lag + atk_stun):
		if i <= atk_lag:
			owner.entity.move_paused = true
		elif i <= atk_lag + atk_stun:
			owner.entity.move_paused = false
			var force: Vector2 = atk_angle_vec.normalized()
			var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, owner.status.percent, owner.entity.get_weight())
			force = force * kb
			#print("knockback: " + str(kb))
			#body.velocity = force
			owner.entity.body_vel = force
		await owner.get_tree().physics_frame
	owner.entity.gravity = owner.entity.GRAVITY
	owner.entity.move_paused = false
	owner.entity.can_move = true
	
