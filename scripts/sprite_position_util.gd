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
			offset.y = -25
		else:
			offset.x = 6
			offset.y = -25
	elif animation == "basic_attack_2":
		if self.flip_h:
			offset.x = -12
			offset.y = -24
		else:
			offset.x = 6
			offset.y = -24
	elif animation == "basic_attack_3":
		if self.flip_h:
			offset.x = -12
			offset.y = -24
		else:
			offset.x = 6
			offset.y = -22
	elif animation == "landing_lag":
		offset.x = 0
		offset.y = -24
	elif animation == "walk_right":
		offset.x = -8
		offset.y = -10
	elif animation == "walk_left":
		offset.x = 0
		offset.y = -10
	#elif animation == "idle" && player.dir.x < 0:
		#offset.x = -8
		#offset.y = 0
	#elif animation == "idle" && player.player_dir < 0:
		#offset.x = -8
		#offset.y = -10
	elif animation == "idle":
		if player.player_dir < 0:
			offset.x = -8
		elif player.player_dir >= 0:
			offset.x = 0
		offset.y = -10
	#elif animation == "in_air" && player.player_dir < 0:
		#offset.x = -6
		#offset.y = 0
	elif animation == "in_air":
		if player.player_dir < 0:
			offset.x = -6
		elif player.player_dir > 0:
			offset.x = 0
		offset.y = -8
	elif animation == "crouch":
		offset.y = -10
	elif animation == "jump_squat":
		offset.y = -10
	else:
		offset.x = 0
		offset.y = 0
	#if animation != "basic_attack_1":
		#offset.x = 0
		#offset.y = 0
		
