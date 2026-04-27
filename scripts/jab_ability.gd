class_name JabAbility extends Ability

@export var input: Node
@export var hitbox: Hitbox

@export_range(0, 360, 1) var angle: float = 0.0
@export_range(0, 500, .1) var bkb: float = 0.0
@export_range(0, 500, .1) var kbg: float = 0.0
@export_range(-100, 100, 1) var xoff: float = 0
@export_range(-100, 100, 1) var yoff: float = 0

@export var hitbox_stats: HitboxStats

var active_window: int = 8
var active_window_start: int = 6
var ability_length: int = 18

var atk_initiated: bool
var frames: int
var active_frames_modifier: int

func _ready() -> void:
	atk_initiated = false
	frames = 0
	active_frames_modifier = 0
	#hitbox.angle = angle
	#hitbox.bkb = bkb
	#hitbox.kbg = kbg

#func tick_ability(input: InputGameComponent, entity: entityComponent, delta: float) -> void:
#func tick_ability(entity: entityManager, delta: float) -> void:
#func tick_ability(entity: entityRes, delta: float) -> void:
func tick_ability(entity: Entity, delta: float) -> void:
	## handle hitbox positioning and orientation
	#hitbox.orientation = entity.orientation
	#hitbox.position.x = abs(hitbox.position.x)*entity.orientation
	#hitbox.set_orientation(entity.orientation)
	#
	### Get player input and initiate attack
	#if (input.btn_1_input &&
		#entity.can_move &&
		#entity.current_state != entity.MoveState.AIRBORNE &&
		#entity.current_state != entity.MoveState.RUNTURN &&
		#entity.body_on_ground &&
		#entity.direction.x < entity.deadzone):
			#atk_initiated = true
			#frames = 0
			#entity.can_move = false
	#
	### Handle initiated attack
	#if atk_initiated:
		#frames += 1
		#if entity.body_vel.length() > 1.0 && !entity.move_paused:
			#entity.decelerate(delta)
		#if entity.hit_connected:
			#active_frames_modifier = hitbox.lag
			#entity.move_paused = true
		#else:
			#active_frames_modifier = 0
			#entity.move_paused = false
		#if frames >= active_window_start && frames < active_window_start + active_window + active_frames_modifier:
			#hitbox.is_active = true
		#else:
			#hitbox.is_active = false
			#entity.hit_connected = false
		#if frames >= ability_length + active_frames_modifier:
			#atk_initiated = false
			#frames = 0
			#active_frames_modifier = 0
			#entity.can_move = true
	#
	### Tick hitbox every frame
	#hitbox.tick(delta)
	pass
	
