extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# fix sprite sheet size inconsistencies
	if animation == "basic_attack_1":
		if self.flip_h:
			offset.x = -4
			offset.y = -15
		else:
			offset.x = 6
			offset.y = -15
		return
	if animation != "basic_attack_1":
		offset.x = 0
		offset.y = 0
