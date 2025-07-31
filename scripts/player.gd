extends RigidBody2D

signal hit

## How fast the player will move (pixels/sec).
@export var speed = 1000
@export var jump_speed = 500
@export var max_movement_speed = 500

@export var left_foot_ray_cast: RayCast2D
@export var right_foot_ray_cast: RayCast2D

var screen_size # Size of the game window.

var lastPlayerMovements = []
var playerMovements = []

func _ready():
	hide()
	screen_size = get_viewport_rect().size

func _process(delta):
	if linear_velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = linear_velocity.x < 0
	if linear_velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = linear_velocity.y > 0
		
	if linear_velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

var start_time = 0
var start_position = Vector2(0.0, 0.0)
var started = false
var time_to_record_in_seconds = 10

func _physics_process(delta: float) -> void:
	if abs(linear_velocity.x) < max_movement_speed:
		apply_central_force(Vector2(Input.get_vector("move_left", "move_right", "move_up", "move_down").x * speed, 0.0))
	if Input.is_action_just_pressed("move_up") and (left_foot_ray_cast.is_colliding() or right_foot_ray_cast.is_colliding()):
		apply_central_impulse(Vector2(0.0, -jump_speed))

func start(pos):
	start_position = pos
	start_time = Time.get_ticks_usec()
	$Ghost.movement = lastPlayerMovements
	$Ghost.movementIndex = 0
	$Ghost.movement_step_multiplier = 1
	started = true
	show()
	$CollisionShape2D.disabled = false

var rot = self.transform.get_rotation()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if started:
		state.transform = Transform2D(0.0, start_position)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		playerMovements.clear()
		started = false
	
	if Time.get_ticks_usec() - start_time < time_to_record_in_seconds * 1000000:
		playerMovements.append(state.transform)
	state.transform = Transform2D(rot, state.transform.origin)

func _on_body_entered(body: Node) -> void:
	if body.has_meta("Enemy") and body.get_meta("Enemy") == "Mob":
		lastPlayerMovements = playerMovements.duplicate(false)
		hide() # Player disappears after being hit.
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		$CollisionShape2D.set_deferred("disabled", true)	
	pass # Replace with function body.
