extends Label

#@onready var player = $"../../Player"
@onready var player: PlayerNew = %PlayerNew


func _physics_process(delta: float) -> void:
	text = str(player.stamina_manager.poise)
