class_name ItemActiveAtkComponent extends BaseComponent

@export var default_hitbox_stats_collection: Array[HitboxShapeStatsList]
var hitbox_stats_collection: Array[HitboxShapeStatsList]

@export var on_hit_effects: Array[OnHitEffect]

#var default_hitboxes: Array[Hitbox]
#var hitboxes: Array[Hitbox]
var hitbox_owner_node: Node2D

var initial_collided_hurtboxes: Array[Hurtbox]

signal atk_connected

var deactivated: bool

func bind(node: Object) -> void:
	super.bind(node)
	deactivated = false
	_generate_move_hitboxes(default_hitbox_stats_collection)
		
func update(delta: float) -> void:
	for i: int in range(hitbox_owner_node.get_child_count()):
		var box: Hitbox = hitbox_owner_node.get_children()[i]
		for statblock in hitbox_stats_collection[i].hitbox_stats_array:
			statblock.is_active = !actor.entity.body_on_ground && !deactivated
		tick_hitbox(box, i, delta)
		if actor.entity.body_on_ground:
			deactivated = false
			if box.collided_hurtboxes.size() > 0:
				box.collided_hurtboxes.clear()
		
func _hitbox_shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D) -> void:
	print(str(hitbox.name) + " hitbox hit " + str(hurtbox.name) + " at shape index " + str(shape_index))
	#for eff: OnReceivedHitEffect in on_received_hit_effects:
		#eff._execute(actor, hitbox, hitbox.get_rid(), shape_index)
	## determine hitbox index to get the right statblock
	var hitbox_idx: int
	#for i: int in range(default_hitboxes.size()):
		#var box: Hitbox = default_hitboxes[i]
	for i: int in range(hitbox_owner_node.get_child_count()):
		var box: Hitbox = hitbox_owner_node.get_children()[i]
		if hitbox.name == box.name:
			hitbox_idx = i
			break
	for eff: OnHitEffect in on_hit_effects:
		eff._execute(self, hurtbox, hitbox, hitbox_idx, shape_index)
	atk_connected.emit()
	
func tick_hitbox(box: Hitbox, box_idx: int, _delta: float) -> void:
	for i in range(default_hitbox_stats_collection[box_idx].hitbox_stats_array.size()):
		var statblock: HitboxStats = default_hitbox_stats_collection[box_idx].hitbox_stats_array[i]
		box.shapes_array[i].set_disabled(!statblock.is_active)
		box.shapes_array[i].visible = statblock.is_active
		box.shapes_array[i].position.x = abs(box.shapes_array[i].position.x)*actor.entity.orientation
		box.shapes_array[i].rotation_degrees = abs(box.shapes_array[i].rotation_degrees)*actor.entity.orientation
		statblock.angle_vec = Vector2(abs(statblock.angle_vec.x)*actor.entity.orientation, statblock.angle_vec.y)
		var angle_dif = box.shape_angle_vis_arr[i].angle_to(statblock.angle_vec)
		box.shape_angle_vis_arr[i] = box.shape_angle_vis_arr[i].rotated(angle_dif)
		
func _generate_move_hitboxes(collection: Array[HitboxShapeStatsList]) -> void:
	hitbox_stats_collection = collection
	#hitboxes.clear()
	if actor.hitboxes.find_child("active_item_hitboxes"):
		actor.hitboxes.find_child("active_item_hitboxes").queue_free()
	if !hitbox_owner_node:
		hitbox_owner_node = Node2D.new()
		hitbox_owner_node.name = "active_item_hitboxes"
		actor.hitboxes.add_child(hitbox_owner_node)
		hitbox_owner_node.owner = actor.hitboxes
	if hitbox_owner_node.get_child_count() > 0:
		for child: Hitbox in hitbox_owner_node.get_children():
			child.disconnect("shape_hit_something", _hitbox_shape_hit_something)
			hitbox_owner_node.remove_child(child)
			child.queue_free()
	for i: int in range(hitbox_stats_collection.size()):
		var new_hitbox: Hitbox = Hitbox.new()
		new_hitbox.owner_hurtbox = actor.hurtbox
		new_hitbox.shape_hit_something.connect(_hitbox_shape_hit_something)
		new_hitbox.set_collision_layer_value(1, false)
		new_hitbox.set_collision_mask_value(1, false)
		new_hitbox.set_collision_mask_value(5, true)
		if initial_collided_hurtboxes.size() > 0:
			for _b in initial_collided_hurtboxes:
				new_hitbox.collided_hurtboxes.append(_b)
		for j: int in range(hitbox_stats_collection[i].hitbox_stats_array.size()):
			var statblock: HitboxStats = hitbox_stats_collection[i].hitbox_stats_array[j]
			var shape: CollisionShape2D = CollisionShape2D.new()
			new_hitbox.shape_angle_vis_arr.append(Vector2(statblock.radius, 0.0)) ## debug
			shape.shape = CapsuleShape2D.new()
			shape.shape.radius = statblock.radius
			shape.shape.height = statblock.height
			shape.position = statblock.pos
			shape.rotation_degrees = statblock.rot * actor.entity.orientation
			shape.visible = statblock.is_active
			statblock.angle_vec = statblock.angle_vec.rotated(deg_to_rad(statblock.angle) * actor.entity.orientation)
			var angle_dif: float = new_hitbox.shape_angle_vis_arr[j].angle_to(statblock.angle_vec)
			new_hitbox.shape_angle_vis_arr[j] = new_hitbox.shape_angle_vis_arr[j].rotated(angle_dif)
			shape.disabled = true
			new_hitbox.add_child(shape)
			shape.owner = new_hitbox
		hitbox_owner_node.add_child(new_hitbox)
		new_hitbox.owner = hitbox_owner_node
		#hitboxes.append(new_hitbox)
