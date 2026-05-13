class_name HitboxStats extends Resource

@export_range(0, 360, 1) var angle: float = 0.0
@export_range(0, 500, .1) var bkb: float = 0.0
@export_range(0, 500, .1) var kbg: float = 0.0

#@export_range(-100, 100, 1) var xoff: float = 0
#@export_range(-100, 100, 1) var yoff: float = 0

@export var lag: int = 4
@export var stun: int = 20
@export_range(0, 360, 1) var rot: float = 0

@export var dmg: float = 0.0

@export var active_window: int = 8
@export var active_window_start: int = 6

var angle_vec: Vector2 = Vector2(1,0)
var is_active: bool = false
var orientation: int = 1
