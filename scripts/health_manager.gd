extends Node
class_name HealthManager

#@onready var hurtbox = $Hurtbox
#@onready var hurtbox = $"../Hurtbox"
#@onready var hurtbox: Hurtbox = %Hurtbox
#@export var hurtbox: Hurtbox
@export_range(0.0, 999.0, 1.0) var percent: float = 0.0

@export var is_inanimate: bool = false

signal hit(area: Area2D)

#func _ready() -> void:
	#hurtbox.hurtbox_hit.connect(_on_hurtbox_hit)
	
func _physics_process(delta: float) -> void:
	pass
	
func _on_hurtbox_hit(area: Area2D):
	if area is Hitbox:
		hit.emit(area)
		if !is_inanimate:
			percent = percent + area.stats.dmg
		print("percent: " + str(percent))
