extends StaticBody2D

@export var movement = []
@export var movementIndex = 0

var movement_step = 1
var movement_step_multiplier = 1

func _physics_process(delta: float) -> void:
	if movementIndex >= 0 and movementIndex < movement.size():
		global_transform = movement[movementIndex]
	
	movementIndex += movement_step * movement_step_multiplier
	
	if movement.size() > 0:
		if movementIndex < 0:
			movement_step = 1
			if movement.size() > movement_step_multiplier * 1.2:
					movement_step_multiplier *= 1.2
		elif movementIndex >= movement.size():
			movement_step = -1
			if movement.size() > movement_step_multiplier * 1.2:
					movement_step_multiplier *= 1.2
