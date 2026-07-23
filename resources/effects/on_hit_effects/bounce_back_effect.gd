class_name BounceBackEffect extends OnHitEffect

func _execute(attacker: Object, _hurtbox: Area2D, _hitbox: Hitbox, _hitbox_index: int, _hitbox_shape_index: int) -> void:
	if attacker is ItemActiveAtkComponent:
		attacker.deactivated = true
		var bounce_vel: Vector2 = (attacker.actor.entity.body_vel.normalized() + Vector2.UP).normalized()
		attacker.actor.entity.body_vel = Vector2.ZERO
		attacker.actor.velocity = Vector2.ZERO
		bounce_vel.x = bounce_vel.x * -1
		bounce_vel.x *= 100
		bounce_vel.y *= 200
		attacker.actor.entity.body_vel = bounce_vel
