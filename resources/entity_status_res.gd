class_name EntityStatus extends Resource

@export_range(0.0, 999.0, 1.0) var percent: float = 0.0

@export var is_inanimate: bool = false

#signal hit(area: Area2D)
#signal hurtbox_hit(area: Area2D, area_rid: RID, area_shape_index: int)

#func init_health(actor: Node2D) -> void:
	#print(str(actor.name) + "hurtbox name: " + str(actor.hurtbox.name))
	#if actor.hurtbox is Hurtbox:
		##actor.hurtbox.hurtbox_hit.connect(_on_hurtbox_hit)
		#actor.hurtbox.hurtbox_was_hit.connect(_on_hurtbox_was_hit)
		
func update_percent(amount: float) -> void:
	print("updating percent!")
	if !is_inanimate:
		percent = percent + amount
	
#func _on_hurtbox_hit(area: Area2D) -> void:
	#if area is Hitbox:
		#hit.emit(area)
		#if !is_inanimate:
			#percent = percent + area.stats.dmg
		#print("percent: " + str(percent))
		#
#func _on_hurtbox_was_hit(area: Area2D, area_rid: RID, area_shape_index: int) -> void:
	#if area is Hitbox:
		#hurtbox_hit.emit(area, area_rid, area_shape_index)
		##if !is_inanimate:
			##percent = percent + area.stats_array[area_shape_index].dmg
		##print("percent: " + str(percent))
