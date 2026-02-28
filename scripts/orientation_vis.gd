extends RayCast2D

@onready var player = $".."

func _physics_process(_delta):
	if player.player_orientation == 0:
		self.target_position.x = -absf(self.target_position.x)
	elif player.player_orientation == 1:
		self.target_position.x = absf(self.target_position.x)
