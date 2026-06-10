class_name InputControlScheme extends Resource

#@export var input_map: Dictionary[String, Variant]

@export var start: Array[String]

#@export var primary_direction: Vector2
#@export var secondary_direction: Vector2

@export var jump: Array[String]

@export var light_atk: Array[String]

@export var heavy_atk: Array[String]

@export var special_atk: Array[String]

@export var guard: Array[String]

@export_enum("light", "heavy", "special") var second_stick_type: String = "light"
