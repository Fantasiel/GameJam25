extends RigidBody2D

signal hit
signal replay

## How fast the player will move (pixels/sec).
@export var speed = 1000
@export var jump_speed = 500
@export var max_movement_speed = 500

@export var left_foot_ray_cast: RayCast2D
@export var right_foot_ray_cast: RayCast2D
@export var feet_ray_cast: RayCast2D

@export var last_player_movements = []
@export var time_to_record_in_seconds = 2

var screen_size # Size of the game window.

var player_movements = []

func _ready():
	hide()
	screen_size = get_viewport_rect().size

var start_time = 0
var start_position = Vector2(0.0, 0.0)
var started = false

func _physics_process(delta: float) -> void:
	if abs(linear_velocity.x) < max_movement_speed:
		apply_central_force(Vector2(Input.get_vector("move_left", "move_right", "move_up", "move_down").x * speed, 0.0))
	if Input.is_action_just_pressed("move_up") and (feet_ray_cast.is_colliding() or left_foot_ray_cast.is_colliding() or right_foot_ray_cast.is_colliding()):
		apply_central_impulse(Vector2(0.0, -jump_speed))
		$AnimatedSprite2D.play("up")
	elif not ($AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "up") and abs(linear_velocity.x) > 0.1 and (feet_ray_cast.is_colliding() or left_foot_ray_cast.is_colliding() or right_foot_ray_cast.is_colliding()):
		$AnimatedSprite2D.play("walk")
	elif not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")
		
	if Input.is_action_just_pressed("replay"):
		replay_with_signal()
	
	if linear_velocity.x != 0.0:
		$AnimatedSprite2D.flip_h = linear_velocity.x < 0.0

	if Input.is_action_just_pressed("die"):
		stop()

func start(pos):
	start_position = pos
	start_time = Time.get_ticks_msec()
	started = true
	show()
	$CollisionShape2D.disabled = false

var rot = self.transform.get_rotation()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if started:
		state.transform = Transform2D(0.0, start_position)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		player_movements.clear()
		started = false
	
	if Time.get_ticks_msec() - start_time >= time_to_record_in_seconds * 1000:
		player_movements.pop_front()
	player_movements.append(state.transform)
	state.transform = Transform2D(rot, state.transform.origin)

func stop() -> void:
	last_player_movements = player_movements
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)	

func replay_with_signal() -> void:
	last_player_movements = player_movements
	replay.emit()
	

func _on_body_entered(body: Node) -> void:
	if body.has_meta("Enemy") and body.get_meta("Enemy") == "Mob":
		stop()

func _on_animated_sprite_2d_animation_looped() -> void:
	if $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "up" and (feet_ray_cast.is_colliding() or left_foot_ray_cast.is_colliding() or right_foot_ray_cast.is_colliding()):
		$AnimatedSprite2D.stop()
	elif $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "walk" and (abs(linear_velocity.x) <= 0.1 or not (feet_ray_cast.is_colliding() or left_foot_ray_cast.is_colliding() or right_foot_ray_cast.is_colliding())):
		$AnimatedSprite2D.stop()
