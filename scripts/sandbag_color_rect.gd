extends ColorRect


func _on_tree_entered() -> void:
	material.set_shader_parameter("width", size.x)
	material.set_shader_parameter("height", size.y)


func _on_item_rect_changed() -> void:
	material.set_shader_parameter("width", size.x)
	material.set_shader_parameter("height", size.y)
