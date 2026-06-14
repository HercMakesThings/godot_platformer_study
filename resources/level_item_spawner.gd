class_name LevelItemSpawner extends Resource

const base_item_scene: PackedScene = preload("res://scenes/article/item/base_item_scene.tscn")

func _init(articles: Node2D) -> void:
	for article: Article in articles.get_children():
		if article is Item:
			article.interacted.connect(_on_item_interacted_with)
		if article is Actor:
			pass

func create_item_scene() -> Item:
	var item: Item = base_item_scene.instantiate()
	return item
	
func assemble_item_profile(item: Item, entity: Entity, components: Array[BaseComponent]) -> Item:
	item.entity = entity
	for comp:BaseComponent in components:
		item.add_component(comp)
	return item
	
func build_entity(texture_2d: Texture2D) -> Entity:
	var e: Entity = Entity.new()
	e.init()
	e.texture_2D = texture_2d
	return e
	
func _on_item_interacted_with(item: Item, user: Article) -> void:
	print(str(item.name) + " interacted with by " + user.name)
	print("despawning item")
	item.despawn()
