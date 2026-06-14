class_name AttackMoveComponent extends Resource

@export var move_name: String

@export var default_hitbox_scenes: Array[PackedScene]

#@export var default_hitbox_stats_array: Array[HitboxStats]
@export var default_hitbox_stats_collection: Array[HitboxShapeStatsList]

@export var ability_length: int = 18

var default_hitboxes: Array[Hitbox]
var hitboxes: Array[Hitbox]
var hitbox_owner: Node2D

var actor: Article

var atk_initiated: bool
var frames: int
var active_frames_modifier: int

signal atk_connected
signal move_completed(newState: AttackComponent.AtkMoveState)

func _init_move(owner: Node) -> void:
	actor = owner
	atk_initiated = false
	frames = 0
	active_frames_modifier = 0
	init_default_hitboxes()
	
func _update(delta: float) -> void:
	print("active frames modifier: " + str(active_frames_modifier))
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
			print("attack ending!")
			for box: Hitbox in hitbox_owner.get_children():
				print("clearing collided hurtboxes")
				box.collided_hurtboxes.clear()
			move_completed.emit(AttackComponent.AtkMoveState.IDLE)
			
	#for box in hitboxes:
	for box: Hitbox in hitbox_owner.get_children():
		if atk_initiated:
			for statblock in box.stats_array:
				if frames >= statblock.active_window_start && frames < statblock.active_window_start + statblock.active_window + active_frames_modifier:
					statblock.is_active = true
				else:
					statblock.is_active = false
		box.set_orientation(actor.entity.orientation)
		box.tick(delta)
	
func init_default_hitboxes() -> void:
	hitboxes.clear()
	if actor.hitboxes.find_child(move_name):
		actor.hitboxes.find_child(move_name).queue_free()
	if !hitbox_owner:
		hitbox_owner = Node2D.new()
		hitbox_owner.name = move_name
		actor.hitboxes.add_child(hitbox_owner)
		hitbox_owner.owner = actor.hitboxes
	if hitbox_owner.get_child_count() > 0:
		for child: Hitbox in hitbox_owner.get_children():
			child.disconnect("shape_hit_something", _hitbox_shape_hit_something)
			hitbox_owner.remove_child(child)
			child.queue_free()
	print(default_hitbox_stats_collection[0].hitbox_stats_array)
	if default_hitboxes.size() == 0:
		for i: int in range(default_hitbox_scenes.size()):
			var box: Hitbox = default_hitbox_scenes[i].instantiate()
			default_hitboxes.append(box)
			print("initializing default hitbox stats")
			#box.init_shape_stats(default_hitbox_stats_collection[i].hitbox_stats_array)
			box.stats_array = default_hitbox_stats_collection[i].hitbox_stats_array
	for box: Hitbox in default_hitboxes:
		box.owner_hurtbox = actor.hurtbox
		box.shape_hit_something.connect(_hitbox_shape_hit_something)
		hitbox_owner.add_child(box)
		hitboxes.append(box)
		box.owner = hitbox_owner
		print(box.stats_array)
		
func init_new_hitboxes(boxes: Array[Hitbox]) -> void:
	hitboxes.clear()
	if actor.hitboxes.find_child(move_name).get_child_count() > 0:
		for child_box: Hitbox in actor.hitboxes.find_child(move_name).get_children():
			child_box.disconnect("shape_hit_something", _hitbox_shape_hit_something)
			child_box.queue_free()
	for box: Hitbox in boxes:
		box.shape_hit_something.connect(_hitbox_shape_hit_something)
		actor.hitboxes.find_child(move_name).add_child(box)
		hitboxes.append(box)
		
func _hitbox_shape_hit_something(hitbox: Area2D, hitbox_shape_index: int, hurtbox: Area2D) -> void:
	print(str(hitbox.name) + " hitbox hit " + str(hurtbox.name) + " at hitbox shape index " + str(hitbox_shape_index))
	#hitbox_shape_hit_something.emit(hitbox, shape_index, hurtbox
	for box in hitboxes:
		if hitbox.name == box.name && atk_initiated:
			active_frames_modifier = box.stats_array[hitbox_shape_index].lag
	atk_connected.emit()
			
func initiate_attack(is_atk_initiated: bool) -> void:
	if is_atk_initiated:
		atk_initiated = true
		frames = 0
		
func _free_all_hitboxes() -> void:
	hitboxes.clear()
	default_hitboxes.clear()
	
