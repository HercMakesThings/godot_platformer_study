extends Node
class_name StaminaManager

@onready var hurtbox = $"../Hurtbox"
@export_range(0.0, 999.0, 1.0) var poise: float = 35.0
@export_range(0.0, 50.0, 1.0) var break_point: float = 0.0
@export_range(0.0, 50.0, 1.0) var poise_max: float = 50.0

func _ready() -> void:
	hurtbox.hurtbox_hit.connect(_on_hurtbox_hit)
	
func _physics_process(delta: float) -> void:
	if poise <= break_point:
		print("broken!")
		poise = poise_max
	if poise < poise_max:
		poise = smoothstep(poise, poise_max, 0.5)
	
func _on_hurtbox_hit(area: Area2D):
	if area is Hitbox:
		poise = poise - area.dmg
