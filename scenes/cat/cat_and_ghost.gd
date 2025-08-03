extends Node2D

const DISTANCE_TO_ENABLE_INTERACTION = 32*32

func replay() -> void:
	$Ghost.recording_data = $Cat.recording_data
	$Cat.recording_data = {}

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("replay"):
		replay()
	
	if $Cat.position.distance_squared_to($Ghost.position) >= DISTANCE_TO_ENABLE_INTERACTION:
		$Cat.set_collision_layer_value(2, true)
		$Ghost.set_collision_layer_value(2, true)


func _on_cat_on_replay() -> void:
	replay()
