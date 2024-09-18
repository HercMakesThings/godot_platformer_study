extends AnimatedSprite2D
@onready var player = $".."


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# fix sprite sheet size inconsistencies
	if animation == "basic_attack_1":
		if self.flip_h:
			#offset.x = -4
			offset.x = -12
			offset.y = -15
		else:
			offset.x = 6
			offset.y = -15
	elif animation == "basic_attack_2":
		if self.flip_h:
			offset.x = -12
			offset.y = -14
		else:
			offset.x = 6
			offset.y = -14
	elif animation == "basic_attack_3":
		if self.flip_h:
			offset.x = -12
			offset.y = -14
		else:
			offset.x = 6
			offset.y = -12
	elif animation == "landing_lag":
		offset.x = 0
		offset.y = -16
	elif animation == "walk_right":
		offset.x = -8
		offset.y = 0
	#elif animation == "idle" && player.dir.x < 0:
		#offset.x = -8
		#offset.y = 0
	elif animation == "idle" && player.player_dir < 0:
		offset.x = -8
		offset.y = 0
	elif animation == "in_air" && player.player_dir < 0:
		offset.x = -6
		offset.y = 0
	else:
		offset.x = 0
		offset.y = 0
	#if animation != "basic_attack_1":
		#offset.x = 0
		#offset.y = 0
		
