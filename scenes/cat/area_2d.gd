extends Area2D

signal died

enum Layers {
	World = 1,
	Player = 2,
	Interactable = 4,
	Trap = 8,
	Slappable = 16,
	Ladder = 32
}


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var cat = get_parent()
	if area is Tuna and not area.was_eaten: 
		area.was_eaten = true;
		area.tuna_eaten.emit()
		print('tuna-eaten')

func _on_body_entered(body: Object) -> void:
	var cat = get_parent()
	if body is Vase and not body.is_broken:
		body.show_slappability_hint.emit(true)
		cat.slappable_bodies[body.get_instance_id()] = body;

func _on_body_exited(body) -> void:
	var cat = get_parent()
	if body is Vase:
		body.show_slappability_hint.emit(false)
		cat.slappable_bodies.erase(body.get_instance_id());

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if PhysicsServer2D.body_get_collision_layer(body_rid) & 8 > 0:
		died.emit()


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if PhysicsServer2D.area_get_collision_layer(area_rid) & 8 > 0:
		died.emit()
