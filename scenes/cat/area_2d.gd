extends Area2D

enum Layers {
	World = 1,
	Player = 2,
	Interactable = 4,
	Trap = 8,
	Slappable = 16,
	Ladder = 32
}

func _on_body_entered(body) -> void:
	var cat = get_parent()
	if body is Vase and not body.is_broken:
		cat.slappable_bodies[body.get_instance_id()] = body;
		

func _on_body_exited(body) -> void:
	var cat = get_parent()
	if body is Vase:
		cat.slappable_bodies.erase(body.get_instance_id());


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if PhysicsServer2D.body_get_collision_layer(body_rid) & 8 > 0:
		print("death")
