class_name TerrainArea2D extends Area2D

@export_enum("Wall", "Floor") var type: String = "Floor"

@onready var collision_shape: Shape2D = $CollisionShape2D.shape
