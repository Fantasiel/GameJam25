extends Node2D

signal victory 

func _ready() -> void:
	self.connect("victory", Callable(self, "_on_victory"))
	
func _on_victory() -> void: 
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/levels/level1/level1.tscn")
