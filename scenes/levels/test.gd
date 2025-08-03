extends Node2D

signal victory 

func _ready() -> void:
	self.connect("victory", Callable(self, "_on_victory"))
	
func _on_victory() -> void: 
	print("VICTORY")
