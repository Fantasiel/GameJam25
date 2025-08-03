extends Node2D

const DISTANCE_TO_ENABLE_INTERACTION = 32*32

func replay() -> void:
	if Input.is_action_just_pressed("replay"):
		$Ghost.recording_data = $Cat.recording_data
		$Cat.recording_data = {}
	
	if $Cat.position.distance_squared_to($Ghost.position) >= DISTANCE_TO_ENABLE_INTERACTION:
		$Cat.set_collision_layer_value(2, true)
		$Ghost.set_collision_layer_value(2, true)

func _physics_process(delta: float) -> void:
	replay()


func _on_cat_on_replay() -> void:
	replay()
