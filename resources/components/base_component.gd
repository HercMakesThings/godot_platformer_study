@abstract class_name BaseComponent extends Resource

var actor: Article

func update(_delta: float) -> void:
	pass

## call super.bind() in inherited components
func bind(node: Object) -> void:
	actor = node
	
func _component_cleanup() -> void:
	pass
