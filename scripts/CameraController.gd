extends SpringArm3D

@export var sensitivity := 0.005
@export var free_look_mode := false  # Toggle between always-rotate and hold-to-rotate
var rotating := false

# Store rotation values
var yaw := 0.0
var pitch := 0.0

# Accumulate mouse delta
var mouse_delta := Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Initialize rotation to match current transform
	yaw = rotation.y
	pitch = rotation.x
	
	# Set collision mask to collide with walls (assuming walls are on layer 1)
	collision_mask = 1

func _input(event):
	# Handle mouse movement - just accumulate the delta
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not free_look_mode or rotating:
			mouse_delta += event.relative
	
	# Handle mouse buttons
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and free_look_mode:
			rotating = event.pressed
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Handle keyboard input
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Apply accumulated mouse movement once per frame
	if mouse_delta.length() > 0:
		yaw -= mouse_delta.x * sensitivity
		pitch = clamp(pitch - mouse_delta.y * sensitivity, deg_to_rad(-60), deg_to_rad(60))
		rotation = Vector3(pitch, yaw, 0)
		
		# Reset accumulator
		mouse_delta = Vector2.ZERO
