class_name KnockbackEffect extends OnHitEffect

@export var hitstun_gravity: float = 4.0

var stun_frames: int = 0

func _execute(attacker: Object, hurtbox: Area2D, _hitbox: Hitbox, hitbox_index: int, hitbox_shape_index: int) -> void:
	#if attacker is not AttackMoveComponent || attacker is not ItemActiveAtkComponent:
		#return
	if hurtbox == null:
		return
	if !attacker.actor:
		return
	#print("knockback eff executed!")
	#print(str(attacker))
	#print(str(attacker.name))
	#(attacker as AttackMoveComponent).actor.entity.can_move = false
	#(attacker as AttackMoveComponent).actor.entity.gravity = hitstun_gravity
	hurtbox.article.entity.can_move = false
	hurtbox.article.entity.gravity = hitstun_gravity
	#var statblock: HitboxStats = (attacker as AttackMoveComponent).default_hitbox_stats_collection[hitbox_index].hitbox_stats_array[hitbox_shape_index]
	var statblock: HitboxStats = attacker.default_hitbox_stats_collection[hitbox_index].hitbox_stats_array[hitbox_shape_index]
	var atk_angle_vec: Vector2 = statblock.angle_vec
	var atk_dmg: float = statblock.dmg
	var atk_bkb: float = statblock.bkb
	var atk_kbg: float = statblock.kbg
	if hurtbox.article is Actor:
		hurtbox.article.status.update_percent(atk_dmg)
	var atk_lag: float = statblock.lag
	var atk_stun: float = statblock.stun
	for i in range(atk_lag + atk_stun):
		if i <= atk_lag:
			hurtbox.article.entity.move_paused = true
		elif i <= atk_lag + atk_stun:
			hurtbox.article.entity.move_paused = false
			var force: Vector2 = atk_angle_vec.normalized()
			var kb: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, hurtbox.article.status.percent, hurtbox.article.entity.get_weight())
			force = force * kb
			#print("knockback: " + str(kb))
			#body.velocity = force
			hurtbox.article.entity.body_vel = force
		await hurtbox.article.get_tree().physics_frame
	hurtbox.article.entity.gravity = hurtbox.article.entity.GRAVITY
	hurtbox.article.entity.move_paused = false
	hurtbox.article.entity.can_move = true
