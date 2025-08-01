extends StaticBody2D

@export var movement = []
@export var movement_index = 0

var movement_step = 1
var movement_step_multiplier = 1

func _physics_process(delta: float) -> void:
	if movement_index >= 0 and movement_index < movement.size():
		transform = movement[movement_index]
	
	movement_index += movement_step * movement_step_multiplier
	
	if movement.size() > 0:
		if movement_index < 0:
			movement_step = 1
			if movement.size() > movement_step_multiplier * 1.2:
					movement_step_multiplier *= 1.2
		elif movement_index >= movement.size():
			movement_step = -1
			if movement.size() > movement_step_multiplier * 1.2:
					movement_step_multiplier *= 1.2


func start(last_player_movement: Array):
	movement = last_player_movement
	movement_index = 0
	movement_step_multiplier = 1
