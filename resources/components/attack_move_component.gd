class_name AttackMoveComponent extends Resource

@export var move_name: String

@export var default_hitbox_stats_collection: Array[HitboxShapeStatsList]
var hitbox_stats_collection: Array[HitboxShapeStatsList]

@export var on_hit_effects: Array[OnHitEffect]

@export var ability_length: int = 18

var default_hitboxes: Array[Hitbox]
var hitboxes: Array[Hitbox]
var hitbox_owner_node: Node2D

var actor: Article

var atk_initiated: bool
var frames: int
var active_frames_modifier: int

var collided_hurtboxes: Array[Hurtbox]

signal atk_connected
signal move_completed(newState: AttackComponent.AtkMoveState)

func _init_move(owner: Node) -> void:
	actor = owner
	atk_initiated = false
	frames = 0
	active_frames_modifier = 0
	generate_move_hitboxes(default_hitbox_stats_collection)
	
func _update(delta: float) -> void:
	## Handle initiated attack
	if atk_initiated:
		actor.entity.can_move = false
		frames += 1
		if actor.entity.body_vel.length() > 1.0 && !actor.entity.move_paused:
			actor.entity.decelerate(delta)
		if active_frames_modifier > 0:
			actor.entity.move_paused = true
		if frames >= ability_length + active_frames_modifier:
			atk_initiated = false
			frames = 0
			active_frames_modifier = 0
			actor.entity.can_move = true
			actor.entity.move_paused = false
			collided_hurtboxes.clear()
			move_completed.emit(AttackComponent.AtkMoveState.IDLE)
			
	for i: int in range(hitboxes.size()):
		var box: Hitbox = hitboxes[i]
		box.set_debug(actor.debug)
		if atk_initiated:
			for statblock in hitbox_stats_collection[i].hitbox_stats_array:
				if frames >= statblock.active_window_start && frames < statblock.active_window_start + statblock.active_window + active_frames_modifier:
					statblock.is_active = true
				else:
					statblock.is_active = false
		tick_hitbox(box, i, delta)
	
func generate_move_hitboxes(collection: Array[HitboxShapeStatsList]) -> void:
	hitbox_stats_collection = collection
	hitboxes.clear()
	if actor.hitboxes.find_child(move_name):
		actor.hitboxes.find_child(move_name).queue_free()
	if !hitbox_owner_node:
		hitbox_owner_node = Node2D.new()
		hitbox_owner_node.name = move_name
		actor.hitboxes.add_child(hitbox_owner_node)
		hitbox_owner_node.owner = actor.hitboxes
	if hitbox_owner_node.get_child_count() > 0:
		for child: Hitbox in hitbox_owner_node.get_children():
			child.disconnect("shape_hit_something", _hitbox_shape_hit_something)
			hitbox_owner_node.remove_child(child)
			child.queue_free()
	for i: int in range(hitbox_stats_collection.size()):
		var new_hitbox: Hitbox = Hitbox.new()
		new_hitbox.shape_hit_something.connect(_hitbox_shape_hit_something)
		new_hitbox.set_collision_layer_value(1, false)
		new_hitbox.set_collision_mask_value(1, false)
		new_hitbox.set_collision_mask_value(5, true)
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
		hitboxes.append(new_hitbox)
		
func _hitbox_shape_hit_something(hitbox: Area2D, hitbox_shape_index: int, hurtbox: Area2D) -> void:
	if hurtbox.get_rid() == actor.hurtbox.get_rid():
		return
	if hurtbox in collided_hurtboxes:
		return
	if !hurtbox.get_parent():
		return
	collided_hurtboxes.append(hurtbox)
	print(str(hitbox.name) + " hitbox hit " + str(hurtbox.name) + " at hitbox shape index " + str(hitbox_shape_index))
	var hitbox_idx: int
	var article: Article = hurtbox.get_parent()
	var c: float = 0.67 if article.entity.current_state == article.entity.MoveState.CROUCH else 1.0
	for i: int in range(hitboxes.size()):
		var box: Hitbox = hitboxes[i]
		if hitbox.name == box.name && atk_initiated:
			var statblock: HitboxStats = hitbox_stats_collection[i].hitbox_stats_array[hitbox_shape_index]
			var electric: float = 1.5 if statblock.tags.has("electric") else 1.0
			var lag: int = floor(floor(floor(statblock.dmg / 3 + 4) * electric) * c)
			active_frames_modifier = lag
			hitbox_idx = i
	for _effect: OnHitEffect in on_hit_effects:
		_effect._execute(self, hurtbox, hitbox, hitbox_idx, hitbox_shape_index)
	atk_connected.emit()
	
func tick_hitbox(box: Hitbox, box_idx: int, _delta: float) -> void:
	for i in range(hitbox_stats_collection[box_idx].hitbox_stats_array.size()):
		var statblock: HitboxStats = hitbox_stats_collection[box_idx].hitbox_stats_array[i]
		box.shapes_array[i].set_disabled(!statblock.is_active)
		box.shapes_array[i].visible = statblock.is_active
		box.shapes_array[i].position.x = abs(box.shapes_array[i].position.x)*actor.entity.orientation
		box.shapes_array[i].rotation_degrees = abs(box.shapes_array[i].rotation_degrees)*actor.entity.orientation
		statblock.angle_vec = Vector2(abs(statblock.angle_vec.x)*actor.entity.orientation, statblock.angle_vec.y)
		var angle_dif = box.shape_angle_vis_arr[i].angle_to(statblock.angle_vec)
		box.shape_angle_vis_arr[i] = box.shape_angle_vis_arr[i].rotated(angle_dif)
			
func initiate_attack(is_atk_initiated: bool) -> void:
	if is_atk_initiated:
		atk_initiated = true
		frames = 0
		
func _free_all_hitboxes() -> void:
	hitboxes.clear()
	default_hitboxes.clear()
	
