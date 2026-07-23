class_name OnHitComponent extends BaseComponent

@export var on_received_hit_effects: Array[OnReceivedHitEffect]

func bind(node: Object) -> void:
	super.bind(node)
	actor.hurtbox.hurtbox_was_hit.connect(_on_hit)
	
func _on_hit(area: Area2D, area_rid: RID, area_shape_index: int) -> void:
	for effect: OnReceivedHitEffect in on_received_hit_effects:
		effect._execute(actor, area, area_rid, area_shape_index)
