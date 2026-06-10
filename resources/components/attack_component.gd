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

var atk_connected: bool

func bind(node: Object) -> void:
	super.bind(node)
	atk_frame = 0
	atk_connected = false
	current_atk_state = AtkMoveState.IDLE
	if side_attack_1:
		side_attack_1._init_move(actor)
		side_attack_1.atk_connected.connect(_on_atk_connected)
		side_attack_1.move_completed.connect(_on_move_completed)
	if side_attack_2:
		side_attack_2._init_move(actor)
		side_attack_2.atk_connected.connect(_on_atk_connected)
		side_attack_2.move_completed.connect(_on_move_completed)
	if side_attack_3:
		side_attack_3._init_move(actor)
		side_attack_3.atk_connected.connect(_on_atk_connected)
		side_attack_3.move_completed.connect(_on_move_completed)
	if down_attack_1:
		down_attack_1._init_move(actor)
		down_attack_1.atk_connected.connect(_on_atk_connected)
		down_attack_1.move_completed.connect(_on_move_completed)
	if down_attack_2:
		down_attack_2._init_move(actor)
		down_attack_2.atk_connected.connect(_on_atk_connected)
		down_attack_2.move_completed.connect(_on_move_completed)
	if down_attack_3:
		down_attack_3._init_move(actor)
		down_attack_3.atk_connected.connect(_on_atk_connected)
		down_attack_3.move_completed.connect(_on_move_completed)
	if up_attack_1:
		up_attack_1._init_move(actor)
		up_attack_1.atk_connected.connect(_on_atk_connected)
		up_attack_1.move_completed.connect(_on_move_completed)
	if up_attack_2:
		up_attack_2._init_move(actor)
		up_attack_2.atk_connected.connect(_on_atk_connected)
		up_attack_2.move_completed.connect(_on_move_completed)
	if up_attack_3:
		up_attack_3._init_move(actor)
		up_attack_3.atk_connected.connect(_on_atk_connected)
		up_attack_3.move_completed.connect(_on_move_completed)

func update(delta: float) -> void:
	#print("current attack state: " + str(current_atk_state))
	handle_attacks(delta)
	
func handle_attacks(delta: float) -> void:
	atk_frame += 1
	var packet: InputPacket = actor.input_component.get_current_packet()
	match current_atk_state:
		AtkMoveState.IDLE:
			_handle_atk_progression(packet, 1)
		AtkMoveState.ATK_1:
			if !side_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			side_attack_1._update(delta)
			_handle_atk_progression(packet, 2)
		AtkMoveState.ATK_2:
			if !side_attack_2:
				change_state(AtkMoveState.IDLE)
				return
			side_attack_2._update(delta)
			_handle_atk_progression(packet, 3)
		AtkMoveState.ATK_3:
			if !side_attack_3:
				change_state(AtkMoveState.IDLE)
				return
			side_attack_3._update(delta)
		AtkMoveState.DOWN_1:
			if !down_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			down_attack_1._update(delta)
			_handle_atk_progression(packet, 2)
		AtkMoveState.DOWN_2:
			if !down_attack_2:
				change_state(AtkMoveState.IDLE)
				return
			down_attack_2._update(delta)
			_handle_atk_progression(packet, 3)
		AtkMoveState.DOWN_3:
			if !down_attack_3:
				change_state(AtkMoveState.IDLE)
				return
			down_attack_3._update(delta)
		AtkMoveState.UP_1:
			if !up_attack_1:
				change_state(AtkMoveState.IDLE)
				return
			up_attack_1._update(delta)
			_handle_atk_progression(packet, 2)
		AtkMoveState.UP_2:
			if !up_attack_2:
				change_state(AtkMoveState.IDLE)
				return
			up_attack_2._update(delta)
			_handle_atk_progression(packet, 3)
		AtkMoveState.UP_3:
			if !up_attack_3:
				change_state(AtkMoveState.IDLE)
				return
			up_attack_3._update(delta)

## Changes current state to @param new and resets frame count.
## Recommended to early return immediately after calling this function
## to prevent an unclean state change
func change_state(new: AtkMoveState) -> void:
	atk_frame = 0
	atk_connected = false
	current_atk_state = new
	
func _on_atk_connected() -> void:
	atk_connected = true
	
func _on_move_completed(new: AtkMoveState) -> void:
	change_state(new)
	
func _handle_atk_progression(packet: InputPacket, next_atk_lvl: int) -> void:
	if !atk_connected && next_atk_lvl != 1:
		return
	if !actor.entity.body_on_ground:
		return
	if !packet.light_atk_just_pressed:
		return
	match packet.primary_direction.y:
		var y when absf(y) < actor.input_component.deadzone_ls:
			match next_atk_lvl:
				1:
					side_attack_1.initiate_attack(true)
					change_state(AtkMoveState.ATK_1)
				2:
					side_attack_2.initiate_attack(true)
					change_state(AtkMoveState.ATK_2)
				3:
					side_attack_3.initiate_attack(true)
					change_state(AtkMoveState.ATK_3)
				_:
					change_state(AtkMoveState.IDLE)
		var y when y < -actor.input_component.deadzone_ls:
			match next_atk_lvl:
				1:
					down_attack_1.initiate_attack(true)
					change_state(AtkMoveState.DOWN_1)
				2:
					down_attack_2.initiate_attack(true)
					change_state(AtkMoveState.DOWN_2)
				3:
					down_attack_3.initiate_attack(true)
					change_state(AtkMoveState.DOWN_3)
				_:
					change_state(AtkMoveState.IDLE)
		var y when y > actor.input_component.deadzone_ls:
			match next_atk_lvl:
				1:
					up_attack_1.initiate_attack(true)
					change_state(AtkMoveState.UP_1)
				2:
					up_attack_2.initiate_attack(true)
					change_state(AtkMoveState.UP_2)
				3:
					up_attack_3.initiate_attack(true)
					change_state(AtkMoveState.UP_3)
				_:
					change_state(AtkMoveState.IDLE)
