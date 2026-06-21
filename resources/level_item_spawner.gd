class_name LevelItemSpawner extends Resource

var level: Level

const base_item_scene: PackedScene = preload("res://scenes/article/item/base_item_scene.tscn")

func _init(_level: Level) -> void:
	level = _level
	for article: Article in level.articles.get_children():
		if article is Item:
			article.interacted.connect(_on_item_interacted_with)
		if article is Actor:
			var itemHandler: ItemHandlerComponent = article.get_component(ItemHandlerComponent)
			if itemHandler:
				itemHandler.item_thrown.connect(_on_item_thrown)

func _create_item_scene() -> Item:
	var item: Item = base_item_scene.instantiate()
	return item
	
func _assemble_item_entity_and_components(item: Item, entity: Entity, components: Array[BaseComponent]) -> Item:
	item.entity = entity
	item.status = _build_item_status_resource()
	for comp:BaseComponent in components:
		item.add_component(comp)
	return item
	
func _build_entity(texture_2d: Texture2D) -> Entity:
	var e: Entity = Entity.new()
	#e.init()
	e.texture_2D = texture_2d
	var ecb_stats = EcbStatsRes.new()
	ecb_stats.height = 8.0
	ecb_stats.center = 4.0
	ecb_stats.left_span = 4.0
	ecb_stats.right_span = 4.0
	ecb_stats.CONTINUOUS_COLLISION_DETECTION = true
	e.ecb_stats = ecb_stats
	return e
	
func _on_item_interacted_with(item: Item, user: Article) -> void:
	print(str(item.name) + " interacted with by " + user.name)
	print("despawning item")
	var itemHandler: ItemHandlerComponent = user.get_component(ItemHandlerComponent)
	if itemHandler:
		itemHandler.hold_item(item.profile)
	item.despawn()
	
func _on_item_thrown(_actor: Article, _location: Node2D, _profile: ItemProfile) -> void:
	print("actor currently throwing: " + str(_actor.name) + ", actor orientation: " + str(_actor.entity.orientation))
	var actor_atk_comp: AttackComponent = _actor.get_component(AttackComponent)
	if actor_atk_comp:
		actor_atk_comp.can_atk = false
	var itemHandler: ItemHandlerComponent = _actor.get_component(ItemHandlerComponent)
	if itemHandler:
		itemHandler.drop_item()
	var item: Item = _create_item_scene()
	var atk_comp: ItemActiveAtkComponent = _build_item_active_atk_component(_actor)
	var on_hit_comp: OnHitComponent = _build_item_on_hit_component()
	#item = _assemble_item_entity_and_components(item, _build_entity(_profile.model), [BaseMovementComponent.new(), atk_comp])
	item = _assemble_item_entity_and_components(
		item, 
		_build_entity(_profile.model),
		[ApplyGravityComp.new(), ApplyFrictionComponent.new(), atk_comp, on_hit_comp]
		#[ApplyGravityComp.new(), ApplyFrictionComponent.new(), atk_comp]
		#[BaseMovementComponent.new(), atk_comp]
	)
	item.profile = _profile
	item.position = _actor.global_position + _location.position
	item.entity.orientation = _actor.entity.orientation
	print("item orientation: " + str(item.entity.orientation))
	print("actor's orientation: " + str(_actor.entity.orientation))
	var packet: InputPacket = _actor.input_component.get_current_packet()
	var actor_dir_normalized: Vector2i = round(_actor.entity.direction.normalized())
	var secondary_dir_normalized: Vector2i = round(packet.secondary_direction.normalized())
	if secondary_dir_normalized.x != 0:
		item.entity.body_vel = Vector2((300 + absf(_actor.entity.body_vel.x)) * secondary_dir_normalized.x, -50)
	elif secondary_dir_normalized.y != 0:
		item.entity.body_vel = Vector2(0, -450 * secondary_dir_normalized.y)
	elif actor_dir_normalized.x != 0:
		item.entity.body_vel = Vector2((300 + absf(_actor.entity.body_vel.x)) * actor_dir_normalized.x, -50)
	elif actor_dir_normalized.y != 0:
		item.entity.body_vel = Vector2(0, -450 * actor_dir_normalized.y)
	elif actor_dir_normalized != Vector2i.ZERO && secondary_dir_normalized != Vector2i.ZERO:
		item.entity.body_vel = Vector2((300 + absf(_actor.entity.body_vel.x)) * item.entity.orientation, -50)
	item.interacted.connect(_on_item_interacted_with)
	level.articles.add_child(item)
	item.owner = level.articles
	
func _build_item_status_resource() -> EntityStatus:
	var s: EntityStatus = EntityStatus.new()
	s.is_inanimate = true
	return s
	
func _build_item_active_atk_component(owner: Actor) -> ItemActiveAtkComponent:
	var c: ItemActiveAtkComponent = ItemActiveAtkComponent.new()
	c.initial_collided_hurtboxes.append(owner.hurtbox)
	#var hb_scene: PackedScene = load("res://scenes/hitboxes/basic_active_item_hitbox1.tscn")
	c.default_hitbox_scenes.append(load("res://scenes/hitboxes/basic_active_item_hitbox1.tscn"))
	c.default_hitbox_stats_collection.append(HitboxShapeStatsList.new())
	var stats: HitboxStats = HitboxStats.new()
	stats.dmg = 4.0
	stats.bkb = 16.0
	stats.kbg = 16.0
	c.default_hitbox_stats_collection[0].hitbox_stats_array.append(stats)
	c.on_hit_effects.append(BounceBackEffect.new())
	return c
	
func _build_item_on_hit_component() -> OnHitComponent:
	var c: OnHitComponent = OnHitComponent.new()
	var on_hit_effects: Array[OnHitEffect]
	on_hit_effects.append(KnockbackEffect.new())
	c.on_hit_effects = on_hit_effects
	return c
	
#func _on_item_picked_up(actor: Article, item: Item) -> void:
	#item.despawn()
