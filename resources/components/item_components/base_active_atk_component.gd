class_name ItemActiveAtkComponent extends BaseComponent

@export var default_hitbox_scenes: Array[PackedScene]

#@export var default_hitbox_stats_array: Array[HitboxStats]
@export var default_hitbox_stats_collection: Array[HitboxShapeStatsList]

@export var on_hit_effects: Array[OnHitEffect]

var default_hitboxes: Array[Hitbox]
#var hitboxes: Array[Hitbox]
var hitbox_owner: Node2D

signal atk_connected

var deactivated: bool

func bind(node: Object) -> void:
	super.bind(node)
	deactivated = false
	init_default_hitboxes()
		
func update(delta: float) -> void:
	for box: Hitbox in hitbox_owner.get_children():
		box.set_orientation(actor.entity.orientation)
		for statblock in box.stats_array:
			statblock.is_active = !actor.entity.body_on_ground && !deactivated
		box.tick(delta)
		if actor.entity.body_on_ground:
			deactivated = false
			if box.collided_hurtboxes.size() > 0:
				box.collided_hurtboxes.clear()
		
func _hitbox_shape_hit_something(hitbox: Area2D, shape_index: int, hurtbox: Area2D) -> void:
	print(str(hitbox.name) + " hitbox hit " + str(hurtbox.name) + " at shape index " + str(shape_index))
	for eff: OnHitEffect in on_hit_effects:
		eff._execute(actor, hitbox, hitbox.get_rid(), shape_index)
	atk_connected.emit()
	
func init_default_hitboxes() -> void:
	if actor.hitboxes.find_child("active_item_hitboxes"):
		actor.hitboxes.find_child("active_item_hitboxes").queue_free()
	if !hitbox_owner:
		hitbox_owner = Node2D.new()
		hitbox_owner.name = "active_item_hitboxes"
		actor.hitboxes.add_child(hitbox_owner)
		hitbox_owner.owner = actor.hitboxes
	if hitbox_owner.get_child_count() > 0:
		for child: Hitbox in hitbox_owner.get_children():
			child.disconnect("shape_hit_something", _hitbox_shape_hit_something)
			hitbox_owner.remove_child(child)
			child.queue_free()
	print(default_hitbox_stats_collection[0].hitbox_stats_array)
	if default_hitboxes.size() == 0:
		for i in range(default_hitbox_scenes.size()):
			var box: Hitbox = default_hitbox_scenes[i].instantiate()
			default_hitboxes.append(box)
			print("initializing default hitbox stats")
			#box.init_shape_stats(default_hitbox_stats_collection[i].hitbox_stats_array)
			box.stats_array = default_hitbox_stats_collection[i].hitbox_stats_array
	for box: Hitbox in default_hitboxes:
		box.owner_hurtbox = actor.hurtbox
		box.shape_hit_something.connect(_hitbox_shape_hit_something)
		hitbox_owner.add_child(box)
		box.owner = hitbox_owner
		print(box.stats_array)
