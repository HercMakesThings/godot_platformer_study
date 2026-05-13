class_name JabMove extends AbilityRes

var name: String = "JabMove"

## TODO: look into either moving active window / start / ability length
## into HitboxStats Resource type, or build a map or dict of hitboxes that contain
## the stats + the move length parameters mentioned above
@export var hitbox_stats_arr: Array[HitboxStats]

@export var hitbox_prefix: String

@export var ability_length: int = 18

var atk_initiated: bool
var frames: int
var active_frames_modifier: int

var hitboxes: Array[Hitbox]

func _init_ability(actor: Node2D) -> void:
	atk_initiated = false
	frames = 0
	active_frames_modifier = 0
	actor.hitbox_manager.hit_something.connect(_on_hit_something)
	#init_hitboxes(actor.hitbox_manager.hitboxes, hitbox_prefix)
	
func _act(actor: Node2D, delta: float) -> void:
	
	## Get player input and initiate attack
	#if (actor.input_game_component.btn_1_input &&
		#actor.entity.can_move &&
		#actor.entity.current_state != actor.entity.MoveState.AIRBORNE &&
		#actor.entity.current_state != actor.entity.MoveState.RUNTURN &&
		#actor.entity.body_on_ground &&
		#actor.entity.direction.x < actor.entity.deadzone):
			#atk_initiated = true
			#frames = 0
			#actor.entity.can_move = false
	initiate_attack(
		actor.input_game_component.btn_1_input &&
		actor.entity.can_move &&
		actor.entity.current_state != actor.entity.MoveState.AIRBORNE &&
		actor.entity.current_state != actor.entity.MoveState.RUNTURN &&
		actor.entity.body_on_ground &&
		actor.entity.direction.x < actor.entity.deadzone &&
		#abs(actor.input_game_component.dir_input.y) < actor.input_game_component.deadzone_ls
		actor.entity.direction.y > -actor.entity.deadzone
	)
		
	
	for box in hitboxes:
		box.set_orientation(actor.entity.orientation)
		if atk_initiated:
			if frames >= box.stats.active_window_start && frames < box.stats.active_window_start + box.stats.active_window + active_frames_modifier:
				box.is_active = true
			else:
				box.is_active = false
		box.tick(delta)
	
	## Handle initiated attack
	if atk_initiated:
		actor.entity.can_move = false
		frames += 1
		if actor.entity.body_vel.length() > 1.0 && !actor.entity.move_paused:
			actor.entity.decelerate(delta)
		if active_frames_modifier > 0:
			actor.entity.move_paused = true
		if frames >= ability_length + active_frames_modifier:
			atk_initiated = false
			frames = 0
			active_frames_modifier = 0
			actor.entity.can_move = true
			actor.entity.move_paused = false
	
func init_hitboxes(boxes: Array, prefix: String) -> void:
	var i: int = 0
	for box in boxes:
		if box is Hitbox && box.name.containsn(prefix):
			box.init_stats(hitbox_stats_arr[i])
			hitboxes.append(box)
		elif box is not Hitbox && box.get_child_count() > 0:
			for child_box in box.get_children():
				if child_box is Hitbox && box.name.containsn(prefix):
					child_box.init_stats(hitbox_stats_arr[i])
					hitboxes.append(child_box)
	i += 1
	
func _on_hit_something(hit_box: Node2D, _hurt_box: Node2D):
	for box in hitboxes:
		if hit_box.name == box.name && atk_initiated:
			active_frames_modifier = box.stats.lag
			
func initiate_attack(is_atk_initiated: bool) -> void:
	if is_atk_initiated:
		atk_initiated = true
		frames = 0
