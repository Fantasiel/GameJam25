extends CharacterBody2D
class_name Cat

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const JUMP_VELOCITY_FACTOR_BEGIN = 0.5 # jump strength at the begin of charging
const JUMP_VELOCITY_FACTOR_END = 2.1 # jump strength at the end of charging
const JUMP_VELOCITY_CHARGE_DURATION = 0.75 * 1000.0 # time in ms it takes to charge the jump
const JUMP_ANGLE_SIDEWARDS = 0.25 * PI # angle when jumping sidewards
const CLIMB_SPEED = 100.0
const FALLING_SPEED = 200.0
const FALLING_BREAKING_SPEED = 1000.0
const FALLING_VERTICAL_THRESHOLD = 1.0
const SLAPPING_FORCE = 300

signal on_replay
signal on_finished_replay


# TODO: maybe need onready for $LadderRayCast2D and $AnimatedSprite2D
# TODO: interact system: reset trigger resets what was interacted with (depends on thing)
# TODO: marker, you are using this cat now
# TODO: replay, change between cats
@export var do_record = true # whether to record, otherwise is ghost and replays
@export var recording_data = {} # holds the recording data, which action is pressed or released
@export var slappable_bodies = {} # tracks nearby slappable bodies
var recording_counter = 0 # counter for both recording and replay
var replay_pressed = {} # remembers which action is pressed during replay
var jump_charge_timestamp = null # start of jump charging, null = not charging
var jump_release_timestamp = -1000000 # moment jump was releases

var actions_to_record = ["move_left", "move_right", "move_up", "move_down", "jump", "interact"]

func replay() -> void:
	recording_counter = 0
	replay_pressed = {}
	position = Vector2.ZERO
	set_collision_layer_value(2, false)

func finished_replay() -> void:
	on_finished_replay.emit()

func _physics_process(delta: float) -> void:
	_enable_cat_or_ghost()
	_record()
	_movement(delta)
	_set_animation()
	move_and_slide()

	# always count up
	recording_counter += 1

func _movement(delta):		
	# jump charging is only possible on ground
	if not is_on_floor():
		jump_charge_timestamp = null

	# handle ladder
	# not_on_floor+action check so that movement changes are not affected while still on floor
	if is_on_ladder() and (not is_on_floor() or _get_input("pressed", "move_down") or _get_input("pressed", "move_up")):
		_ladder_climb(delta)
		return

	# handle jump
	if is_on_floor():
		if _get_input("pressed", "jump"):
			if jump_charge_timestamp == null:
				jump_charge_timestamp = Time.get_ticks_msec()
			velocity.x = 0
			return
		if _get_input("released", "jump"):
			_jump(delta)
			# maybe exploitable, so just reset charge timestamp after jump
			jump_charge_timestamp = null
			return

	# handle falling
	if not is_on_floor():
		_falling(delta) 
		return

	# handle interact
	if _get_input("pressed", "interact"):
		$AnimatedSprite2D.play("interact")
	if is_interacting():
		velocity = Vector2.ZERO # intentionally not moving when interacting
		return

	# handle walk
	_normal_walk(delta)

func _ladder_climb(_delta):
	var direction := Vector2.ZERO

	# only full directions
	#direction.x = Input.get_axis("move_left", "move_right")
	#direction.y = Input.get_axis("move_up", "move_down")
	if _get_input("pressed", "move_left"):
		direction.x -= 1
	if _get_input("pressed", "move_right"):
		direction.x += 1
	if _get_input("pressed", "move_down"):
		direction.y += 1
	if _get_input("pressed", "move_up"):
		direction.y -= 1

	if direction:
		velocity = direction.normalized() * CLIMB_SPEED
	else:
		velocity = Vector2.ZERO

func _normal_walk(_delta):
	# only full directions
	#var direction := Input.get_axis("move_left", "move_right")
	var direction := 0
	if _get_input("pressed", "move_left"):
		direction -= 1
	if _get_input("pressed", "move_right"):
		direction += 1

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _jump(delta) -> void:
	var angle = 0.0
	if _get_input("pressed", "move_left"):
		angle = JUMP_ANGLE_SIDEWARDS
	if _get_input("pressed", "move_right"):
		angle = -JUMP_ANGLE_SIDEWARDS
	var jump_direction = Vector2(sin(angle), cos(angle))
	
	var charge_ratio = _calculate_jump_charge_ratio()
	
	var jump_factor = (1.0 - charge_ratio) * JUMP_VELOCITY_FACTOR_BEGIN + charge_ratio * JUMP_VELOCITY_FACTOR_END
	var jump_velocity = JUMP_VELOCITY * jump_factor
	
	velocity = jump_direction * jump_velocity;
	jump_release_timestamp = Time.get_ticks_msec()
	
func _calculate_jump_charge_ratio() -> float:
	if not jump_charge_timestamp:
		return 0.0
	return clamp((Time.get_ticks_msec() - jump_charge_timestamp) / JUMP_VELOCITY_CHARGE_DURATION, 0.0, 1.0)

func _falling(delta) -> void: 
	# Add the gravity
	velocity += get_gravity() * delta
	
	var direction = 0;
	if _get_input("pressed", "move_left"):
		direction = -1.0
	if _get_input("pressed", "move_right"):
		direction = 1.0
		
	# if the character is faster than the normal speed and player moves in the opposite direction: slow it
	if FALLING_SPEED < abs(velocity.x):
		if velocity.x * direction < 0.0:
			velocity.x += direction * delta * FALLING_BREAKING_SPEED 
	else:
		velocity.x = direction * FALLING_SPEED

func _set_animation() -> void:	
	# handle direction
	if velocity.x < 0 || _get_input("pressed", "move_left"):
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0 || _get_input("pressed", "move_right"):
		$AnimatedSprite2D.flip_h = false

	# keep interact if already in there (will reset via _on_animation_finished())
	if is_interacting():
		return
		
	# handle ladder
	if is_on_ladder() and not is_on_floor():
		if velocity:
			$AnimatedSprite2D.play("climb")
		else:
			$AnimatedSprite2D.stop()
		return
		
	# handle jump charging
	if jump_charge_timestamp != null:
		if _calculate_jump_charge_ratio() < 0.95:
			$AnimatedSprite2D.play("charge_start")
		else:
			$AnimatedSprite2D.play("charge_full")
		return
		
	# falling
	if not is_on_floor():
		var time_since_jump = Time.get_ticks_msec() - jump_release_timestamp
		if time_since_jump < 0.25 * 1000:
			$AnimatedSprite2D.play("charge_release")
		elif abs(velocity.y) < FALLING_VERTICAL_THRESHOLD:
			$AnimatedSprite2D.play("fly_horizontal")
		elif velocity.y < 0.0:
			$AnimatedSprite2D.play("fly_up")
		else:
			$AnimatedSprite2D.play("fly_down")
		return
		
	if not do_record and recording_counter > recording_data.keys().back():
		$AnimatedSprite2D.play("charge_full")
		return	
	
	# handle walk
	if velocity:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

func is_on_ladder():
	return ($LadderRayCast2D.get_collider())

func can_interact():
	return ($InteractRayCast2D.get_collider())

func is_interacting():
	return ($AnimatedSprite2D.animation == "interact")

# record key presses and releases
func _record():
	var dict := {}
	if do_record:
		for action_to_record in actions_to_record:
			if Input.is_action_just_pressed(action_to_record):
				dict["pressed_" + action_to_record] = true
			if Input.is_action_just_released(action_to_record):
				dict["released_" + action_to_record] = true

		if not dict.is_empty():
			recording_data[recording_counter] = dict

func _get_input(type, action):
	# if we are recording, we return the real input
	if do_record:
		if type == "just_pressed":
			return Input.is_action_just_pressed(action);
		elif type == "pressed":
			return Input.is_action_pressed(action)
		elif type == "released":
			return Input.is_action_just_released(action)
	else: # we are replaying the recording
		var just_released = {}
		if recording_data.has(recording_counter):
			if recording_data[recording_counter].has(str("pressed", "_", action)):
				replay_pressed.set(action, true)
			if recording_data[recording_counter].has(str("released", "_", action)):
				replay_pressed.erase(action)
				just_released.set(action, true)
		elif recording_data and recording_counter > recording_data.keys().back():
			finished_replay()
			return false
		if type == "pressed":
			return replay_pressed.has(action)
		elif type == "released":
			return just_released.has(action)

# interact animation is not looping, so we need to wait for it to end before we can change it
# otherwise the animation is cut short if we change it to something else
func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "interact":
		$AnimatedSprite2D.play("idle")
		
		for slappable_body in slappable_bodies.values():
			slappable_body.velocity += SLAPPING_FORCE * position.direction_to(slappable_body.position);

func _enable_cat_or_ghost():
	if do_record: # actual player
		$CollisionShape2D.disabled = false
	elif not recording_data.is_empty(): # or the ghost got data
		$CollisionShape2D.disabled = false
		$".".visible = true


func _on_area_2d_died() -> void:
	if do_record:
		on_replay.emit()
