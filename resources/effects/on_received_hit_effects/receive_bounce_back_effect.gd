class_name ReceiveBounceBackEffect extends OnReceivedHitEffect

func _execute(owner: Object, _area: Area2D, _area_rid: RID, _area_shape_index: int) -> void:
	if owner is not Item:
		return
	var atk_comp: ItemActiveAtkComponent = owner.get_component(ItemActiveAtkComponent)
	if atk_comp: 
		atk_comp.deactivated = true
	var bounce_vel = owner.entity.body_vel.normalized()
	owner.entity.body_vel = Vector2.ZERO
	owner.velocity = Vector2.ZERO
	bounce_vel.x = bounce_vel.x * -1
	bounce_vel.x *= 100
	bounce_vel.y *= 800
	owner.entity.body_vel = bounce_vel
