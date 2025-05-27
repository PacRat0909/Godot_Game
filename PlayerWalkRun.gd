class_name PlayerWalkRun extends EntityState

func enter() -> void:
	print("Entered Walk State")

func physics_update(_delta: float) -> void:
	var input_direction := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (entity.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	var current_speed = entity.speed
	if entity.is_object_held:
		current_speed *= entity.held_object_speed_multiplier
		if entity.picked_object != null:
			var object_mass = entity.picked_object.mass
			current_speed -= object_mass * entity.mass_slowdown_factor
			current_speed = max(0.3, current_speed)

	if direction:
		entity.velocity.x = direction.x * current_speed
		entity.velocity.z = direction.z * current_speed
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, current_speed)
		entity.velocity.z = move_toward(entity.velocity.z, 0, current_speed)

	if not entity.is_on_floor():
		entity.change_state(PlayerAirState.new(entity))  
		return

	if Input.is_action_just_pressed("Jump"):
		entity.change_state(PlayerJump.new(entity)) 
