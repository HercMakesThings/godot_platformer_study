class_name ArticleDefinition extends Resource

@export var entity: Entity

@export var components: Array[BaseComponent]

## Item specific
@export var item_profile: ItemProfile

func _init(_entity: Entity = Entity.new(), _components: Array[BaseComponent] = []) -> void:
	entity = _entity
	for c: BaseComponent in _components:
		components.append(c)
