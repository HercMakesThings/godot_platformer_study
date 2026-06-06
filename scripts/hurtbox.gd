extends Area2D
class_name Hurtbox

#signal hurtbox_hit(hitbox: Hitbox)

signal hurtbox_was_hit(hitbox: Hitbox, area_rid: RID, area_shape_index: int)

func _ready() -> void:
	area_shape_entered.connect(_on_hurtbox_area_shape_entered)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("atk_hitbox_group") and area is Hitbox:
		#print(area.dmg)
		#hurtbox_hit.emit(area)
		pass

func _on_hurtbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, _local_shape_index: int):
	if area is Hitbox && area.owner_hurtbox.get_rid() != get_rid():
		#print("area_rid: " + str(area_rid))
		#print("area_shape_index: " + str(area_shape_index))
		#print("local_shape_index:" + str(local_shape_index))
		hurtbox_was_hit.emit(area, area_rid, area_shape_index)
	
