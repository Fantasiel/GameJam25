extends Area2D

class_name Tuna

signal tuna_eaten

enum TunaModel { TunaA = 0, TunaB = 1 }

@export var model: TunaModel
@export var was_eaten = false

var is_falling = false
var was_on_floor = false 
var falling_start_timestamp = null


func _physics_process(delta: float) -> void:
	_set_sprite(delta)

func _set_sprite(delta) -> void:
	$Tuna_a.visible = model == TunaModel.TunaA
	$Tuna_b.visible = model == TunaModel.TunaB
