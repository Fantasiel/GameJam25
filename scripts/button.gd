extends Area2D

signal start_pressing
signal stop_pressing

func _on_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.play("press")
	start_pressing.emit()


func _on_body_exited(body: Node2D) -> void:
	$AnimatedSprite2D.play("press", -1.0, true)
	stop_pressing.emit()
