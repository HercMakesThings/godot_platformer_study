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

func create_item_scene() -> Item:
	var item: Item = base_item_scene.instantiate()
	return item
	
func assemble_item(item: Item, entity: Entity, components: Array[BaseComponent]) -> Item:
	item.entity = entity
	for comp:BaseComponent in components:
		item.add_component(comp)
	return item
	
func build_entity(texture_2d: Texture2D) -> Entity:
	var e: Entity = Entity.new()
	#e.init()
	e.texture_2D = texture_2d
	var ecb_stats = EcbStatsRes.new()
	ecb_stats.height = 8.0
	ecb_stats.center = 4.0
	ecb_stats.left_span = 4.0
	ecb_stats.right_span = 4.0
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
	var itemHandler: ItemHandlerComponent = _actor.get_component(ItemHandlerComponent)
	if itemHandler:
		itemHandler.drop_item()
	var item: Item = create_item_scene()
	var atk_comp: ItemActiveAtkComponent = _build_item_active_atk_component()
	item = assemble_item(item, build_entity(_profile.model), [BaseMovementComponent.new(), atk_comp])
	item.profile = _profile
	print("item orientation: " + str(item.entity.orientation))
	#item.entity.STARTING_VELOCITY = Vector2(900, -50)
	#item.entity.STARTING_VELOCITY.x = absf(item.entity.STARTING_VELOCITY.x) * _actor.entity.orientation
	#item.entity.STARTING_VELOCITY.x = absf(item.entity.STARTING_VELOCITY.x) * item.entity.orientation
	item.position = _actor.global_position + _location.position
	item.entity.orientation = _actor.entity.orientation
	if _actor.entity.direction.y < -_actor.entity.deadzone:
		item.entity.body_vel = _actor.velocity + Vector2(0, 900)
	elif _actor.entity.direction.y > _actor.entity.deadzone:
		item.entity.body_vel = _actor.velocity + Vector2(0, -900)
	else:
		item.entity.body_vel = _actor.velocity + Vector2(900, -50)
		item.entity.body_vel.x = absf(item.entity.body_vel.x) * item.entity.orientation
	item.interacted.connect(_on_item_interacted_with)
	level.articles.add_child(item)
	item.owner = level.articles
	
func _build_item_active_atk_component() -> ItemActiveAtkComponent:
	var c: ItemActiveAtkComponent = ItemActiveAtkComponent.new()
	c.default_hitbox_scenes.append(load("res://scenes/hitboxes/basic_active_item_hitbox1.tscn"))
	c.default_hitbox_stats_collection.append(HitboxShapeStatsList.new())
	var stats: HitboxStats = HitboxStats.new()
	stats.dmg = 4.0
	stats.bkb = 16.0
	stats.kbg = 16.0
	c.default_hitbox_stats_collection[0].hitbox_stats_array.append(stats)
	c.on_hit_effects.append(BounceBackEffect.new())
	return c
	
#func _on_item_picked_up(actor: Article, item: Item) -> void:
	#item.despawn()
