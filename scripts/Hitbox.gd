extends Area2D

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready from hitbox!")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if player.dir != 0:
		#position.x = position.x * player.dir

func _physics_process(delta):
	#pass
	print("player direction: " + str(player.dir))
	if player.dir != 0:
		position.x = position.x * player.dir * delta * 60
	#else:
		#position.x = position.x * player.prev_dir

func _on_body_entered(body):
	print("ping!")
