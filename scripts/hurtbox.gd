extends Area2D
class_name Hurtbox

#signal hurtbox_hit(hitbox: Hitbox)

signal hurtbox_was_hit(hitbox: Hitbox, area_rid: RID, area_shape_index: int)

func _ready() -> void:
	monitoring = false
	#area_shape_entered.connect(_on_hurtbox_area_shape_entered)
	pass
	
func contacted(area: Area2D, area_rid: RID, area_shape_index: int) -> void:
	hurtbox_was_hit.emit(area, area_rid, area_shape_index)

#func _on_hurtbox_area_entered(area: Area2D) -> void:
	#if area.is_in_group("atk_hitbox_group") and area is Hitbox:
		##print(area.dmg)
		##hurtbox_hit.emit(area)
		#pass
#
#func _on_hurtbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int):
	#if area is not Hitbox:
		#return
	### return if hitbox is owned by this entity
	#if area.owner_hurtbox.get_rid() == get_rid():
		#return
	#if area.collided_hurtboxes.has(self):
		#return
	#if area is Hitbox && area.owner_hurtbox.get_rid() != get_rid():
		#hurtbox_was_hit.emit(area, area_rid, area_shape_index)
	
