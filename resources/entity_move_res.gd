class_name EntityMoveRes extends Resource

func compute_movement(entity: Entity, delta: float) -> void:
	## early return for when ability or game mechanic needs
	## to pause the character entirely
	if entity.move_paused:
		return
	
	if entity.STARTING_VELOCITY != Vector2.ZERO:
		entity.body_vel = entity.STARTING_VELOCITY
		entity.STARTING_VELOCITY = Vector2.ZERO
	
	handle_state(entity, delta)
	entity.move_state_frame = entity.move_state_frame + 1
	return
	
func handle_state(entity: Entity, delta: float) -> void:
	match entity.current_state:
		entity.MoveState.IDLE:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.direction.x > entity.deadzone:
					entity.orientation = 1
				elif entity.direction.x < -entity.deadzone:
					entity.orientation = -1
				if abs(entity.direction.x) >= entity.deadzone && abs(entity.direction.x) < entity.hard_press_thresh:
					entity.change_state(entity.MoveState.WALK)
					return
				elif abs(entity.direction.x) >= entity.hard_press_thresh && entity.move_state_frame > 0:
					entity.change_state(entity.MoveState.DASH)
					return
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				if entity.direction.y <= -entity.deadzone + -entity.crouch_thresh:
					entity.change_state(entity.MoveState.CROUCH)
					return
				if entity.body_vel.length() > 0.0:
					entity.decelerate(delta)
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.WALK:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.move_state_frame < 3 && abs(entity.direction.x) >= entity.hard_press_thresh:
					entity.change_state(entity.MoveState.DASH)
					return
				if absf(entity.direction.x) < entity.deadzone:
					if entity.body_vel.length() < 1.0 && entity.move_state_frame >= 3:
						entity.change_state(entity.MoveState.IDLE)
						return
					entity.decelerate(delta, 5.0)
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				if entity.direction.y < -entity.deadzone + -entity.crouch_thresh:
					entity.change_state(entity.MoveState.CROUCH)
					return
				#entity.apply_accel(entity.walk_force, delta)
				entity.apply_force(entity.walk_force, delta)
				# Clamp speed
				#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_WALK_SPD, entity.MAX_WALK_SPD)
				#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_WALK_SPD*absf(entity.direction.x), entity.MAX_WALK_SPD*absf(entity.direction.x))
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.DASH:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.direction.normalized().dot(entity.body_vel.normalized()) <= 0:
					if entity.direction.normalized().dot(entity.body_vel.normalized()) < -entity.deadzone:
						if absf(entity.direction.y) <= entity.hard_press_thresh:
							entity.body_vel.x = 0
							entity.accel = Vector2.ZERO
							entity.change_state(entity.MoveState.IDLE)
							return
					elif entity.direction.normalized().dot(entity.body_vel.normalized()) == 0:
						if entity.body_vel.length() < 1.0 && entity.move_state_frame >= 3:
							entity.change_state(entity.MoveState.IDLE)
							return
						entity.decelerate(delta)
				#if entity.direction.normalized().dot(entity.body_vel.normalized()) < -entity.deadzone:
				##if abs(entity.direction.dot(entity.body_vel)) < entity.deadzone:
##					## clamp y direction to allow for moonwalking
					#print("direction dot body_vel: " + str(entity.direction.dot(entity.body_vel)))
					#print("going to idle!")
					#if absf(entity.direction.y) <= entity.hard_press_thresh:
						#entity.body_vel.x = 0
						#entity.accel = Vector2.ZERO
						#entity.change_state(entity.MoveState.IDLE)
						#return
				if entity.move_state_frame >= entity.dash_time:
					#if abs(entity.direction.x) >= entity.hard_press_thresh:
					entity.change_state(entity.MoveState.RUN)
					return
				#if abs(entity.direction.x) < entity.deadzone:
					#if entity.body_vel.length() < 1.0 && entity.move_state_frame >= 3:
						#entity.change_state(entity.MoveState.IDLE)
						#return
					#entity.decelerate(delta)
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				#entity.apply_accel(entity.dash_force, delta)
				#entity.apply_accel(Vector2(entity.dash_force.x*entity.orientation, entity.dash_force.y), delta, false)
				entity.apply_force(entity.dash_force, delta)
				# Clamp speed
				entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED, entity.MAX_SPEED)
				#if absf(entity.direction.x) < entity.deadzone:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED*entity.deadzone, entity.MAX_SPEED*entity.deadzone)
				#else:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED*absf(entity.direction.x), entity.MAX_SPEED*absf(entity.direction.x))
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.RUN:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.move_state_frame >= 3 && (entity.orientation * entity.direction.x) < 0:
					if entity.direction.x > entity.deadzone:
						entity.orientation = 1
					elif entity.direction.x < -entity.deadzone:
						entity.orientation = -1
				if entity.direction.dot(entity.body_vel) < -entity.deadzone:
					entity.change_state(entity.MoveState.RUNTURN)
					return
				if abs(entity.direction.x) < entity.deadzone:
					if entity.body_vel.length() < 1.0 && entity.move_state_frame >= 3:
						entity.change_state(entity.MoveState.IDLE)
						return
					entity.decelerate(delta)
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				if entity.direction.y < -entity.deadzone + -entity.crouch_thresh:
					entity.change_state(entity.MoveState.CROUCH)
					return
				entity.apply_accel(entity.run_force, delta)
				#entity.apply_force(entity.run_force, delta)
				# clamp speed
				entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED, entity.MAX_SPEED)
				#if absf(entity.direction.x) < entity.deadzone:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED*entity.deadzone, entity.MAX_SPEED*entity.deadzone)
				#else:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_SPEED*absf(entity.direction.x), entity.MAX_SPEED*absf(entity.direction.x))
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.RUNTURN:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.direction.x > entity.deadzone:
					entity.orientation = 1
				elif entity.direction.x < -entity.deadzone:
					entity.orientation = -1
				if abs(entity.direction.x) < entity.deadzone:
					if entity.body_vel.length() < 1.0:
						entity.change_state(entity.MoveState.IDLE)
						return
					entity.decelerate(delta)
				if entity.direction.y < -entity.deadzone + -entity.crouch_thresh:
					entity.change_state(entity.MoveState.CROUCH)
					return
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				if entity.body_vel.x == 0.0:
					entity.change_state(entity.MoveState.RUN)
					return
				if entity.direction.dot(entity.body_vel) < 0:
					entity.decelerate(delta, 0.45)
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.JUMPSQUAT:
			if entity.body_on_ground:
				if entity.jump_released:
					entity.is_short_jump = true
				if entity.move_state_frame >= 4:
					if entity.is_short_jump:
						#apply_accel(Vector2(0,JUMP_VELOCITY))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY))
						#apply_accel(delta)
						entity.body_vel.y = entity.JUMP_VELOCITY*entity.SHORT_JUMP_MOD
						entity.is_short_jump = false
						entity.change_state(entity.MoveState.AIRBORNE)
						return
					else:
						#apply_accel(Vector2(0,JUMP_VELOCITY*0.65))
						#accel = calc_accel(Vector2(0,JUMP_VELOCITY*0.65))
						#apply_accel(delta)
						entity.body_vel.y = entity.JUMP_VELOCITY
						entity.is_short_jump = false
						entity.change_state(entity.MoveState.AIRBORNE)
						return
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.AIRBORNE:
			if entity.body_on_ground:
				if entity.body_vel.y > 0:
					entity.body_vel.y = 0
				#if !on_ground:
					#on_ground = true
					##if !contact_point.is_colliding():
					#if !contact_point:
						#entity.change_state(MoveState.IDLE)
						#return
					#else:
						#entity.change_state(MoveState.LANDLAG)
						#return
				#else:
					#entity.change_state(MoveState.LANDLAG)
					#return
				#if !entity.contact_point:
				if entity.on_ground:
					entity.change_state(entity.MoveState.IDLE)
					return
				else:
					entity.on_ground = true
					entity.change_state(entity.MoveState.LANDLAG)
					return
			else:
				entity.apply_gravity()
				if !entity.can_move:
					return
				if entity.on_ground:
					entity.on_ground = false
				## fast falling
				if entity.body_vel.y >= 0.0:
					if (entity.direction.y < -entity.hard_press_thresh && 
						abs(entity.direction.x) < entity.deadzone &&
						entity.can_move
					):
						entity.body_vel.y = move_toward(entity.body_vel.y, entity.TERMINAL_VELOCITY, entity.run_speed)
				entity.apply_accel(entity.dash_force, delta)
				#entity.apply_force(entity.dash_force, delta)
				entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_AIR_SPEED, entity.MAX_AIR_SPEED)
				#if absf(entity.direction.x) < entity.deadzone:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_AIR_SPEED*entity.deadzone, entity.MAX_AIR_SPEED*entity.deadzone)
				#else:
					#entity.body_vel.x = clamp(entity.body_vel.x, -entity.MAX_AIR_SPEED*absf(entity.direction.x), entity.MAX_AIR_SPEED*absf(entity.direction.x))
		entity.MoveState.LANDLAG:
			if entity.body_on_ground:
				if entity.move_state_frame >= entity.LANDING_LAG:
					entity.change_state(entity.MoveState.IDLE)
					return
				else:
					entity.decelerate(delta, 5.0)
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
		entity.MoveState.CROUCH:
			if entity.body_on_ground:
				if !entity.can_move:
					return
				if entity.direction.y >= -entity.deadzone + -entity.crouch_thresh:
					entity.change_state(entity.MoveState.IDLE)
					return
				if entity.jump_just_pressed || entity.jump_pressed:
					entity.change_state(entity.MoveState.JUMPSQUAT)
					return
				entity.decelerate(delta)
			else:
				entity.on_ground = false
				entity.change_state(entity.MoveState.AIRBORNE)
				return
