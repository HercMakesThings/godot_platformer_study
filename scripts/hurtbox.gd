extends Area2D
class_name Hurtbox

signal hurtbox_hit

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("atk_hitbox_group") and area is Hitbox:
		#print(area.dmg)
		hurtbox_hit.emit(area)
