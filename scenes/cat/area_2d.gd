extends Area2D

func _on_body_entered(body) -> void:
	var cat = get_parent()
	if body is Vase and not body.is_broken:
		cat.slappable_bodies[body.get_instance_id()] = body;
		

func _on_body_exited(body) -> void:
	var cat = get_parent()
	if body is Vase:
		cat.slappable_bodies.erase(body.get_instance_id());
