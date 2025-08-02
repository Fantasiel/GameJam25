extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const CLIMB_SPEED = 70

# TODO: maybe need onready for $LadderRayCast2D and $AnimatedSprite2D

# TODO: jump high and jump far
# TODO: interact system: reset trigger resets what was interacted with (depends on thing)
# TODO: marker, you are using this cat now
# TODO: replay, change between cats
@export var do_record = true # whether to record or to replay
@export var cat = 1 # which cat number this is
var recording_data = {} # holds the recording data, which action is pressed or released
var recording_counter = 0 # counter for both recording and replay
var replay_pressed = {} # remembers which action is pressed during replay

func _physics_process(delta: float) -> void:
	_record()
	_movement(delta)
	_set_animation()
	move_and_slide()

	if Input.is_action_just_pressed("replay"):
		print(recording_data)
		recording_counter = 0
		do_record = !do_record
		replay_pressed = {}
		if do_record:
			recording_data = {}
	# TODO: reset cat position
 
	# always count up
	recording_counter += 1

func _movement(delta):
	# Add the gravity
	if not is_on_floor(): # and not is_on_ladder?
		velocity += get_gravity() * delta

	# handle jump
	if _get_input("released", "jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# handle ladder
	# not_on_floor+action check so that movement changes are not affected while still on floor
	if is_on_ladder() and (not is_on_floor() or _get_input("pressed", "move_down") or _get_input("pressed", "move_up")):
		_ladder_climb(delta)
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
		# TODO: you are faster if you go 2 directions... this should not be
		velocity = direction * CLIMB_SPEED
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

func _set_animation() -> void:
	# handle direction
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
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
		# TODO: do a loop with action as items
		if Input.is_action_just_pressed("move_left"):
			dict["pressed_move_left"] = true
		if Input.is_action_just_pressed("move_right"):
			dict["pressed_move_right"] = true
		if Input.is_action_just_pressed("move_up"):
			dict["pressed_move_up"] = true
		if Input.is_action_just_pressed("move_down"):
			dict["pressed_move_down"] = true
		if Input.is_action_just_pressed("jump"):
			dict["pressed_jump"] = true
		
		if Input.is_action_just_released("move_left"):
			dict["released_move_left"] = true
		if Input.is_action_just_released("move_right"):
			dict["released_move_right"] = true
		if Input.is_action_just_released("move_up"):
			dict["released_move_up"] = true
		if Input.is_action_just_released("move_down"):
			dict["released_move_down"] = true
		if Input.is_action_just_released("jump"):
			dict["released_jump"] = true

		if not dict.is_empty():
			recording_data[recording_counter] = dict

func _get_input(type, action):
	# if we are recording, we return the real input
	if do_record:
		if type == "pressed":
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
		if type == "pressed":
			return replay_pressed.has(action)
		elif type == "released":
			return just_released.has(action)

# interact animation is not looping, so we need to wait for it to end before we can change it
# otherwise the animation is cut short if we change it to something else
func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "interact":
		$AnimatedSprite2D.play("idle")
