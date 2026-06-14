class_name Item extends Article

@export var profile: ItemProfile

signal interacted(item: Item, user: Article)

func interact_with(user: Article) -> void:
	interacted.emit(self, user)
	
func despawn() -> void:
	queue_free()
