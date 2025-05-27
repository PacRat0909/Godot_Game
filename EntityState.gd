class_name EntityState extends Resource

var entity: CharacterBody3D 

func _init(p_entity: CharacterBody3D):
	entity = p_entity

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
