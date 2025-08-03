extends Area2D

class_name Tuna

signal tuna_eaten

enum TunaModel { TunaA = 0, TunaB = 1 }

@export var model: TunaModel
@export var was_eaten = false

var initial_transform: Transform2D

func _ready() -> void:
	initial_transform = self.transform
	for cat in self.get_parent().find_children("*", "Cat"):
		if cat is Cat and cat.do_record:
			cat.connect("on_started_replay", Callable(self, "_on_started_replay"))

func _physics_process(delta: float) -> void:
	_set_sprite(delta)

func _set_sprite(delta) -> void:
	$Tuna_a.visible = model == TunaModel.TunaA and not was_eaten
	$Tuna_b.visible = model == TunaModel.TunaB and not was_eaten

func _on_started_replay() -> void:
	self.transform = initial_transform
	was_eaten = false
	
