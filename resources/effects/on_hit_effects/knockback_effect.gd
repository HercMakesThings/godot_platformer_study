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
	if !hurtbox.get_parent():
		return
	if hurtbox.get_parent() is not Article:
		return
	var article: Article = hurtbox.get_parent() ## entity being knocked back
	article.entity.can_move = false
	article.entity.gravity = hitstun_gravity
	var statblock: HitboxStats = attacker.default_hitbox_stats_collection[hitbox_index].hitbox_stats_array[hitbox_shape_index]
	var atk_angle_vec: Vector2 = statblock.angle_vec
	var atk_dmg: float = statblock.dmg
	var atk_bkb: float = statblock.bkb
	var atk_kbg: float = statblock.kbg
	if article is Actor:
		article.status.update_percent(atk_dmg)
	var electric: float = 1.5 if statblock.tags.has("electric") else 1.0
	var c: float = 0.67 if article.entity.current_state == article.entity.MoveState.CROUCH else 1.0
	var lag: int = floor(floor(floor(atk_dmg / 3 + 4) * electric) * c)
	lag = clamp(lag, 2, 30)
	var atk_lag: float = lag
	var knockback: float = FlushyUtils.calc_kb_no_area(atk_bkb, atk_kbg, atk_dmg, article.status.percent, article.entity.get_weight())
	var bonus_stun: int = 5 if statblock.tags.has("strong") else 0
	var atk_stun: int = floor(knockback * 0.4) + bonus_stun
	for i in range(atk_lag + atk_stun):
		if i <= atk_lag:
			article.entity.move_paused = true
		elif i <= atk_lag + atk_stun:
			article.entity.move_paused = false
			var force: Vector2 = atk_angle_vec.normalized()
			force = force * knockback
			article.entity.body_vel = force
		await article.get_tree().physics_frame
	article.entity.gravity = article.entity.GRAVITY
	article.entity.move_paused = false
	article.entity.can_move = true
