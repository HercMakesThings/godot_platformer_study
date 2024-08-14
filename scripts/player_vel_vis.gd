extends Line2D

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_point_position(1, player.velocity * 0.08)
	#set_point_position(1, Vector2(player.velocity.x, 0) * 0.05)
