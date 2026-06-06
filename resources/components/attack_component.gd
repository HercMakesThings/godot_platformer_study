class_name AttackComponent extends BaseComponent

@export var side_attack_1: AttackMoveComponent
@export var side_attack_2: AttackMoveComponent
@export var side_attack_3: AttackMoveComponent
@export var down_attack_1: AttackMoveComponent
@export var down_attack_2: AttackMoveComponent
@export var down_attack_3: AttackMoveComponent
@export var up_attack_1: AttackMoveComponent
@export var up_attack_2: AttackMoveComponent
@export var up_attack_3: AttackMoveComponent

enum AtkMoveState {IDLE, ATK_1, ATK_2, ATK_3, DOWN_1, DOWN_2, DOWN_3, UP_1, UP_2, UP_3}

var current_atk_state: AtkMoveState

var atk_frame: int = 0

func bind(node: Object) -> void:
	super.bind(node)
	atk_frame = 0
	current_atk_state = AtkMoveState.IDLE
	if side_attack_1:
		side_attack_1._init_move(actor)
		side_attack_1.move_completed.connect(_on_move_completed)
	if side_attack_2:
		side_attack_2._init_move(actor)
		side_attack_2.move_completed.connect(_on_move_completed)
	if side_attack_3:
		side_attack_3._init_move(actor)
		side_attack_3.move_completed.connect(_on_move_completed)
	if down_attack_1:
		down_attack_1._init_move(actor)
		down_attack_1.move_completed.connect(_on_move_completed)
	if down_attack_2:
		down_attack_2._init_move(actor)
		down_attack_2.move_completed.connect(_on_move_completed)
	if down_attack_3:
		down_attack_3._init_move(actor)
		down_attack_3.move_completed.connect(_on_move_completed)
	if up_attack_1:
		up_attack_1._init_move(actor)
		up_attack_1.move_completed.connect(_on_move_completed)
	if up_attack_2:
		up_attack_2._init_move(actor)
		up_attack_2.move_completed.connect(_on_move_completed)
	if up_attack_3:
		up_attack_3._init_move(actor)
		up_attack_3.move_completed.connect(_on_move_completed)

func update(delta) -> void:
	#print("current attack state: " + str(current_atk_state))
	handle_attacks(delta)
	
func handle_attacks(delta: float) -> void:
	atk_frame += 1
	match current_atk_state:
		AtkMoveState.IDLE:
			var packet: InputPacket = actor.input_component.get_current_packet()
			if (packet.light_atk_just_pressed && actor.entity.body_on_ground):
				if packet.primary_direction.y < actor.input_component.deadzone_ls:
					side_attack_1.initiate_attack(true)
					change_state(AtkMoveState.ATK_1)
					return
				elif packet.primary_direction.y < -actor.input_component.deadzone_ls:
					down_attack_1.initiate_attack(true)
					change_state(AtkMoveState.UP_1)
					return
				elif packet.primary_direction.y > actor.input_component.deadzone_ls:
					up_attack_1.initiate_attack(true)
					change_state(AtkMoveState.DOWN_1)
					return
		AtkMoveState.ATK_1:
			if !side_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			#if atk_frame >= side_attack_1.ability_length + side_attack_1.active_frames_modifier:
			##if side_attack_1.frames >= side_attack_1.ability_length + side_attack_1.active_frames_modifier:
				#change_state(AtkMoveState.IDLE)
				#return
			side_attack_1._update(delta)
		AtkMoveState.ATK_2:
			if !side_attack_2:
				change_state(AtkMoveState.IDLE)
				return
		AtkMoveState.ATK_3:
			if !side_attack_3:
				change_state(AtkMoveState.IDLE)
				return
		AtkMoveState.DOWN_1:
			if !down_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			if down_attack_1.frames >= down_attack_1.ability_length + down_attack_1.active_frames_modifier:
				change_state(AtkMoveState.IDLE)
				return
			down_attack_1._update(delta)
		AtkMoveState.DOWN_2:
			if !down_attack_2:
				change_state(AtkMoveState.IDLE)
				return
		AtkMoveState.DOWN_3:
			if !down_attack_3:
				change_state(AtkMoveState.IDLE)
				return
		AtkMoveState.UP_1:
			if !up_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			if up_attack_1.frames >= up_attack_1.ability_length + up_attack_1.active_frames_modifier:
				change_state(AtkMoveState.IDLE)
				return
			up_attack_1._update(delta)
		AtkMoveState.UP_2:
			if !up_attack_2:
				change_state(AtkMoveState.IDLE)
				return
		AtkMoveState.UP_3:
			if !up_attack_3:
				change_state(AtkMoveState.IDLE)
				return


## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: AtkMoveState) -> void:
	atk_frame = 0
	current_atk_state = new
	
func _on_move_completed(new: AtkMoveState) -> void:
	change_state(new)
