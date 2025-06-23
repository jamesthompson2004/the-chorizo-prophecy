extends CharacterBody3D

# Movement settings
@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var rotation_speed: float = 10.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0

# Jump settings
@export var jump_velocity: float = 8.0
@export var gravity: float = 20.0
@export var max_fall_speed: float = 30.0

# Camera reference
var camera_rig: SpringArm3D

# State tracking
var is_sprinting: bool = false

func _ready():
	camera_rig = $CameraRig
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Handle gravity and jumping
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = max(velocity.y, -max_fall_speed)
	else:
		# Allow jumping only when on floor
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	
	# Check for sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else speed
	
	# Gather movement input
	var input_dir = Vector2(
		Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)
	
	# Normalize input but preserve analog stick partial values
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()
	
	# Calculate movement based on camera orientation
	if input_dir.length() > 0.1:
		# Get camera's forward and right vectors (relative to world, not player)
		var cam_basis = camera_rig.global_transform.basis
		var forward = -cam_basis.z
		forward.y = 0
		forward = forward.normalized()
		var right = cam_basis.x
		right.y = 0
		right = right.normalized()
		
		# Calculate movement direction
		var move_dir = (right * input_dir.x + forward * input_dir.y).normalized()
		
		# Apply movement with acceleration
		var target_velocity = move_dir * current_speed * input_dir.length()
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
		
		# Smoothly rotate character to face movement direction
		if move_dir.length() > 0.1:
			var target_transform = transform.looking_at(global_position + move_dir, Vector3.UP)
			transform.basis = transform.basis.slerp(target_transform.basis, rotation_speed * delta)
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
		# Optional: Slowly rotate to face camera direction when idle
		if camera_rig and not camera_rig.get("rotating"):
			var cam_forward = -camera_rig.global_transform.basis.z
			cam_forward.y = 0
			if cam_forward.length() > 0.1:
				cam_forward = cam_forward.normalized()
				var target_transform = transform.looking_at(global_position + cam_forward, Vector3.UP)
				transform.basis = transform.basis.slerp(target_transform.basis, rotation_speed * delta * 0.5)
	
	# Apply movement
	move_and_slide()

# Optional: Add some debug info or state getters
func is_moving() -> bool:
	return velocity.length() > 0.1

func get_horizontal_velocity() -> float:
	return Vector2(velocity.x, velocity.z).length()

func get_movement_state() -> String:
	if not is_on_floor():
		return "airborne"
	elif is_sprinting and is_moving():
		return "sprinting"
	elif is_moving():
		return "walking"
	else:
		return "idle"
