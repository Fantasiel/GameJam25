extends Node2D

@export var next_scene: PackedScene

var tunas: Array[Tuna] = []
var vases: Array[Vase] = []

var has_won = false
var tuna_eaten = 0
var vases_broken = 0

func _ready() -> void:
	for cat in self.get_parent().find_children("*", "Cat"):
		if cat is Cat and cat.do_record:
			cat.connect("on_started_replay", Callable(self, "_on_started_replay"))
	for tuna in self.get_parent().find_children("*", "Tuna"):
		if tuna is Tuna:
			tuna.connect("tuna_eaten", Callable(self, "_on_tuna_eaten"))
			tunas.append(tuna)
	for vase in self.get_parent().find_children("*", "Vase"):
		if vase is Vase:
			vase.connect("vase_broken", Callable(self, "_on_vase_broken"))
			vases.append(vase)
			
func _physics_process(delta: float) -> void:
	var a = 1	
	
func _check_victory():
	var all_tunas_eaten = tuna_eaten == tunas.size()
	var all_vases_broken = vases_broken == vases.size()
	
	if all_tunas_eaten and all_vases_broken:
		$CanvasLayer.visible = true
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_packed(next_scene)
	
func _on_started_replay(): 
	tuna_eaten = 0 
	vases_broken = 0
	
func _on_tuna_eaten():
	tuna_eaten += 1
	print('tunas', tuna_eaten)
	_check_victory()
	
func _on_vase_broken():
	vases_broken += 1
	print('vases', vases_broken)
	_check_victory()
	
	
	
