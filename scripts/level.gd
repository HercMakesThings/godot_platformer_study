class_name Level extends Node2D

@onready var articles: Node2D = %Articles
@onready var terrain: Node2D = %Terrain

var item_spawner: LevelItemSpawner

func _ready() -> void:
	item_spawner = LevelItemSpawner.new(self)
