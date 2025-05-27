class_name PlayerJump extends EntityState

func enter() -> void:
	print("Entered Jump State")
	var current_horizontal_velocity = Vector3(entity.velocity.x, 0, entity.velocity.z)
	entity.velocity.y = entity.jump_acceleration
	entity.velocity.x = current_horizontal_velocity.x
	entity.velocity.z = current_horizontal_velocity.z
	entity.change_state(PlayerAirState.new(entity))

func handle_input(_event: InputEvent) -> void:
	pass
