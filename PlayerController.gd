extends CharacterBody3D

@export var speed = 4 
@export var jump_acceleration = 5
@export var fall_velocity = 20
@export var air_control: float = 0.1
@export var air_deceleration_factor: float = 0.02

@onready var anim_player = $AnimatePlayer
@onready var camera = $Head/Camera3D
@onready var head = $Head
var _mouse_motion_accum = Vector2.ZERO

@onready var interaction = $Head/Camera3D/Interaction
@onready var hand = $Head/Camera3D/Hand
@onready var weap_hitbox =$"Head/Camera3D/WeaponPivot/Weapon Mesh/Weapon Hitbox"

@export var inventory_data: InventoryData

var picked_object: RigidBody3D = null 
var is_object_held: bool = false 

@export var pull_power = 12
@export var pickup_distance_threshold: float = 0.5

@export var hold_distance: float = 1.7
@export var hold_offset_x: float = 0.0
@export var hold_offset_y: float = -1
@export var held_object_rotation_degrees: Vector3 = Vector3(35, 0, 0)

@export var held_object_speed_multiplier: float = 0.6
@export var mass_slowdown_factor: float = 0.05

var current_entity_state: EntityState = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	change_state(PlayerWalkRun.new(self))

func change_state(new_state: EntityState) -> void:
	if current_entity_state != null:
		current_entity_state.exit()
	current_entity_state = new_state
	if current_entity_state != null:
		current_entity_state.enter()

func _physics_process(delta: float) -> void:
	if current_entity_state != null:
		current_entity_state.physics_update(delta)
	move_and_slide() 
	if picked_object != null:
		if is_object_held:
			picked_object.linear_velocity = Vector3.ZERO
			picked_object.angular_velocity = Vector3.ZERO
		else:
			var object_position = picked_object.global_position
			var target_position = hand.global_position
			var obj_distance = object_position.distance_to(target_position)
			if obj_distance < pickup_distance_threshold:
				var obj_direction = object_position.direction_to(target_position)
				var pull_action = obj_direction * pull_power * obj_distance
				picked_object.set_linear_velocity(pull_action)
				picked_object.set_angular_velocity(picked_object.angular_velocity*0.5)
			else:
				is_object_held = true
				picked_object.freeze = true
				print("Object is now held!")

func _unhandled_input(event: InputEvent): 
	if event is InputEventMouseMotion:
		_mouse_motion_accum += event.relative 

	if Input.is_action_just_pressed("Interact"):
		pick_object()

	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

	if Input.is_action_just_pressed("Attack"):
		anim_player.stop()
		anim_player.play("SwingAttack")
		weap_hitbox.monitoring = true

func _process(_delta: float) -> void:
	if picked_object != null and is_object_held:
		var desired_hold_position = camera.global_position 			+ (-camera.global_transform.basis.z * hold_distance) 			+ (camera.global_transform.basis.x * hold_offset_x) 			+ (camera.global_transform.basis.y * hold_offset_y)
		picked_object.global_position = desired_hold_position

		var camera_rotation_basis = camera.global_transform.basis
		var additional_rotation_basis = Basis()
		additional_rotation_basis = additional_rotation_basis.rotated(Vector3.RIGHT, deg_to_rad(held_object_rotation_degrees.x))
		additional_rotation_basis = additional_rotation_basis.rotated(Vector3.UP, deg_to_rad(held_object_rotation_degrees.y))
		additional_rotation_basis = additional_rotation_basis.rotated(Vector3.FORWARD, deg_to_rad(held_object_rotation_degrees.z))
		picked_object.transform.basis = camera_rotation_basis * additional_rotation_basis

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-_mouse_motion_accum.x * 0.005)
		camera.rotate_x(-_mouse_motion_accum.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -(PI/3), (PI/3))
		_mouse_motion_accum = Vector2.ZERO

func _on_animate_player_animation_finished(_anim_name: StringName):
	weap_hitbox.monitoring = false
	anim_player.stop()
	anim_player.play("Idle Animation")

func _on_weapon_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		print("Enemy hit")

func pick_object():
	var collider = interaction.get_collider()
	if picked_object == null:
		if collider != null and collider is RigidBody3D:
			picked_object = collider
			is_object_held = false
			print("Attempting to pick up object.")
		else: 
			print("No pickable object found by raycast.")
	else:
		drop_object()

func drop_object():
	if picked_object != null:
		is_object_held = false
		picked_object.freeze = false
		picked_object.set_linear_velocity(Vector3.ZERO)
		picked_object.set_angular_velocity(Vector3.ZERO)
		picked_object = null
		print("Object dropped!")
