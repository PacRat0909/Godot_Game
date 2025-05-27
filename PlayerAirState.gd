class_name PlayerAirState extends EntityState

func enter() -> void:
	print("Entered Air State")

func physics_update(delta: float) -> void:
	var input_direction := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (entity.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

	var current_speed = entity.speed 
	if entity.is_object_held:
		current_speed *= entity.held_object_speed_multiplier
		if entity.picked_object != null:
			var object_mass = entity.picked_object.mass
			current_speed -= object_mass * entity.mass_slowdown_factor
			current_speed = max(0.3, current_speed)

	var current_horizontal_velocity = Vector3(entity.velocity.x, 0, entity.velocity.z)
	var desired_horizontal_velocity = direction * current_speed

	entity.velocity.x = lerp(current_horizontal_velocity.x, desired_horizontal_velocity.x, entity.air_control)
	entity.velocity.z = lerp(current_horizontal_velocity.z, desired_horizontal_velocity.z, entity.air_control)

	entity.velocity.x = move_toward(entity.velocity.x, 0, entity.air_deceleration_factor * entity.speed)
	entity.velocity.z = move_toward(entity.velocity.z, 0, entity.air_deceleration_factor * entity.speed)

	entity.velocity.y -= entity.fall_velocity * delta

	if entity.is_on_floor():
		entity.change_state(PlayerWalkRun.new(entity))
