extends CharacterBody2D
class_name Vase

signal vase_broken
signal show_slappability_hint

const FALLING_SPIN_RATE = PI / 2
const IS_FALLING_THRESHOLD = 100.0

@export var model = 1 # 1, 2 or 3
@export var is_broken = false
@export var enable_slappability_hint = false # show a hint on screen, that the vase is slappable


var is_falling = false
var was_on_floor = false 
var falling_start_timestamp = null


func _physics_process(delta: float) -> void:
	_check_breaking()
	_movement(delta)
	_set_sprite(delta)
	move_and_slide()
		
func _check_breaking() -> void:
	if is_on_floor(): 
		was_on_floor = true
	if is_on_floor() and is_falling:
		is_broken = true
		is_falling = false
		velocity = Vector2.ZERO
		process_mode = Node.PROCESS_MODE_DISABLED
		
		vase_broken.emit()

func _movement(delta: float) -> void: 
	if is_on_floor():
		return
	velocity += get_gravity() * delta
	if abs(velocity.y) > 5.0:
		if falling_start_timestamp == null: 
			falling_start_timestamp = Time.get_ticks_msec()
		if was_on_floor:
			is_falling = true


func _set_sprite(delta) -> void:
	$Vase_1_pristine.visible = model == 1 and not is_broken
	$Vase_1_broken.visible = model == 1 and is_broken
	$Vase_2_pristine.visible = model == 2 and not is_broken
	$Vase_2_broken.visible = model == 2 and is_broken
	$Vase_3_pristine.visible = model == 3 and not is_broken
	$Vase_3_broken.visible = model == 3 and is_broken
	
	if is_falling:
		self.rotate(delta * FALLING_SPIN_RATE)
	else:
		self.rotation = 0
		
func _on_show_slappability_hint(visible: bool) -> void:
	$SlapVaseLabel.visible = enable_slappability_hint and visible and not is_broken
