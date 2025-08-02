extends Node2D

const DISTANCE_TO_ENABLE_INTERACTION = 32*32

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("replay"):
		$Ghost.recording_data = $Cat.recording_data
		$Cat.recording_data = {}
	
	if $Cat.position.distance_squared_to($Ghost.position) >= DISTANCE_TO_ENABLE_INTERACTION:
		$Cat.set_collision_layer_value(1, true)
		$Ghost.set_collision_layer_value(1, true)
