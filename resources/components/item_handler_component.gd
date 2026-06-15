class_name ItemHandlerComponent extends BaseComponent

var item_interact_box: Area2D
var is_item_in_range

var items_in_range: Array[Item]

signal pickup_item(actor: Article, item: Item)

func bind(node: Object) -> void:
	super.bind(node)
	_init_pickup_range()
	
func update(_delta: float) -> void:
	if !is_item_in_range:
		return
	var packet: InputPacket = actor.input_component.get_current_packet()
	if packet.light_atk_just_pressed:
		var item: Item = _get_highest_priority_item()
		pickup_item.emit(actor, item)
		
func grab_item(profile: ItemProfile) -> void:
	pass
		
func _get_highest_priority_item() -> Item:
	var highest_priority: int = -int(INF)
	var _item: Item
	for item in items_in_range:
		if item.profile.pickup_priority > highest_priority:
			highest_priority = item.profile.pickup_priority
			_item = item
	if highest_priority == 0:
		_item = items_in_range[0]
	return _item
	
func _on_item_entered_range(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	if area.get_parent() is not Item:
		return
	print("item in range! Item: " + str(area.get_parent().name))
	item_interact_box.visible = true
	is_item_in_range = true
	items_in_range.append(area.get_parent())
	var atk_comp: AttackComponent = actor.get_component(AttackComponent)
	if atk_comp:
		atk_comp.can_atk = false
	
func _on_item_exited_range(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	if area.get_parent() is not Item:
		return
	print("item exited range! Item: " + str(area.get_parent().name))
	item_interact_box.visible = false
	is_item_in_range = false
	if items_in_range.has(area.get_parent()):
		items_in_range.erase(area.get_parent())
	var atk_comp: AttackComponent = actor.get_component(AttackComponent)
	if atk_comp:
		atk_comp.can_atk = true
		
func _init_pickup_range() -> void:
	item_interact_box = Area2D.new()
	var box_shape: CollisionShape2D = CollisionShape2D.new()
	box_shape.shape = RectangleShape2D.new()
	box_shape.shape.size = Vector2(24, 36)
	box_shape.set_disabled(false)
	item_interact_box.position.y = -16.0
	item_interact_box.monitorable = false
	item_interact_box.monitoring = true
	item_interact_box.visible = false
	#item_interact_box.visible = true
	item_interact_box.set_collision_layer_value(1, false)
	item_interact_box.set_collision_mask_value(1, false)
	item_interact_box.set_collision_mask_value(5, true)
	item_interact_box.add_child(box_shape)
	actor.add_child(item_interact_box)
	item_interact_box.owner = actor
	item_interact_box.area_entered.connect(_on_item_entered_range)
	item_interact_box.area_exited.connect(_on_item_exited_range)
