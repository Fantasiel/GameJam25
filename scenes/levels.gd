extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on__pressed_1() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1/level1.tscn")
func _on__pressed_2() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level2/level2.tscn")
func _on__pressed_3() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level3/level3.tscn")
func _on__pressed_4() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level4/level4.tscn")
func _on__pressed_5() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level5/level5.tscn")
func _on__pressed_6() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level6/level6.tscn")
