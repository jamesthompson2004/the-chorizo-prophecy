extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.002

var rotation_x := 0.0
@onready var camera_pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D

func _ready():
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, deg_to_rad(-60), deg_to_rad(60))
		camera_pivot.rotation.x = rotation_x

func _physics_process(delta):
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply movement direction to velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravity and jump
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	move_and_slide()
