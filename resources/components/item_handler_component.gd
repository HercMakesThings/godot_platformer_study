class_name ItemHandlerComponent extends BaseComponent

var item_interact_box: Area2D
var item_spawn_location: Node2D
var held_item_visual: Sprite2D

var is_item_in_range

var items_in_range: Array[Item]

var _held_item_profile: ItemProfile

#signal pickup_item(actor: Article, item: Item)
signal item_thrown(actor: Article, location: Node2D, profile: ItemProfile)

func bind(node: Object) -> void:
	super.bind(node)
	_init_pickup_range()
	_init_item_spawn_location()
	_init_held_item_visual()
	
func update(_delta: float) -> void:
	if _held_item_profile:
		_handle_throw_item()
	if is_item_in_range && !_held_item_profile:
		_handle_interact_with_item_in_range()
	item_spawn_location.position.x = absf(item_spawn_location.position.x) * actor.entity.orientation
	held_item_visual.position.x = absf(held_item_visual.position.x) * actor.entity.orientation
		
func _handle_interact_with_item_in_range() -> void:
	#if !is_item_in_range:
		#return
	var packet: InputPacket = actor.input_component.get_current_packet()
	#var pickup_input_just_pressed: bool = packet.light_atk_just_pressed if actor.entity.body_on_ground else packet.is_guard_just_pressed
	var pickup_input_just_pressed: bool
	if packet.light_atk_just_pressed:
		pickup_input_just_pressed = true
	#if packet.is_guard_just_pressed && (actor.input_component.get_buffer(actor.entity.JUMP_SQUAT_LENGTH).find_custom(func(_p): return _p.)
	#print("jump just pressed: " + str(actor.input_component.get_buffer(4)[0].jump_just_pressed))
	if !pickup_input_just_pressed:
		if !actor.entity.body_on_ground && packet.is_guard_just_pressed:
			pickup_input_just_pressed = true
	if !pickup_input_just_pressed:
		#var is_jump_buffered: bool
		for _p: InputPacket in (actor as Actor).input_component.get_buffer(actor.entity.JUMP_SQUAT_LENGTH):
			print(str(_p.jump_pressed) + ", and " + str(packet.is_guard_pressed))
			if _p.jump_pressed && packet.is_guard_pressed:
				pickup_input_just_pressed = true
				break
			#if _p.jump_just_pressed:
				#is_jump_buffered = true
				#break
		#if is_jump_buffered && packet.is_guard_pressed:
			#pickup_input_just_pressed = true
	if pickup_input_just_pressed && actor.entity.can_move:
		var item: Item = _get_highest_priority_item()
		#pickup_item.emit(actor, item)
		item.interact_with(actor)
		
func _handle_throw_item() -> void:
	#if !_held_item_profile:
		#return
	var packet: InputPacket = actor.input_component.get_current_packet()
	#var throw_input_just_pressed: bool = packet.light_atk_just_pressed if actor.entity.body_on_ground else packet.is_guard_just_pressed
	if packet.light_atk_just_pressed && actor.entity.can_move:
		#var actor_dir_normalized: Vector2i = round(actor.entity.direction.normalized())
		#if actor_dir_normalized.x != 0:
			#actor.entity.orientation = actor_dir_normalized.x
		item_thrown.emit(actor, item_spawn_location, _held_item_profile)
		
func hold_item(profile: ItemProfile) -> void:
	_held_item_profile = profile
	held_item_visual.texture = _held_item_profile.model
	
func drop_item() -> void:
	_held_item_profile = null
	held_item_visual.texture = null
		
func _get_highest_priority_item() -> Item:
	var highest_priority: int = -int(INF)
	var _item: Item
	for item: Item in items_in_range:
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
	items_in_range.append(area.get_parent())
	is_item_in_range = items_in_range.size() > 0
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
	if items_in_range.has(area.get_parent()):
		items_in_range.erase(area.get_parent())
	is_item_in_range = items_in_range.size() > 0
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
	
func _init_item_spawn_location() -> void:
	item_spawn_location = Node2D.new()
	item_spawn_location.position = Vector2(15, -16)
	actor.add_child(item_spawn_location)
	item_spawn_location.owner = actor
	
func _init_held_item_visual() -> void:
	held_item_visual = Sprite2D.new()
	held_item_visual.position = Vector2(16, -36)
	if _held_item_profile:
		held_item_visual.texture = _held_item_profile.model
	actor.add_child(held_item_visual)
	held_item_visual.owner = actor
