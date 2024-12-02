extends Camera2D

@export var min_zoom := 0.7
@export var max_zoom := 2.0
@export var zoom_factor := 0.1
@export var zoom_duration := 0.2

var _target_zoom := 1.0
var cursor: Node
var is_panning = false
var last_mouse_position: Vector2

func _ready() -> void:
	_target_zoom = zoom.x
	# Connect to the cursor's edge_reached signal
	cursor = get_node("../Cursor")  # Get the Cursor node that's a sibling under GameBoard
	print(cursor)
	cursor.edge_reached.connect(_on_edge_reached)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in
			_target_zoom = min(_target_zoom + zoom_factor, max_zoom)
			_smooth_zoom(_target_zoom, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out
			_target_zoom = max(_target_zoom - zoom_factor, min_zoom)
			_smooth_zoom(_target_zoom, event.position)
		# Check for right mouse button press
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				last_mouse_position = event.position
			else:
				is_panning = false

	# Handle panning when the right mouse button is held down
	if is_panning and event is InputEventMouseMotion:
		var delta = event.position - last_mouse_position
		position -= delta / zoom.x  # Adjust position based on mouse movement
		last_mouse_position = event.position  # Update last mouse position

func _smooth_zoom(target_zoom: float, mouse_position: Vector2) -> void:
	# Get the mouse position in viewport coordinates
	var mouse_pos = mouse_position - get_viewport_rect().size * 0.5
	
	# Get where the mouse is before zooming
	var mouse_world_pos = mouse_pos / zoom.x
	
	# Create the zoom tween
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", Vector2.ONE * target_zoom, zoom_duration)
	
	# Move the camera so the mouse stays in the same place
	var new_mouse_world_pos = mouse_pos / target_zoom
	var new_offset = position + (mouse_world_pos - new_mouse_world_pos)
	tween.parallel().tween_property(self, "position", new_offset, zoom_duration)

func _on_edge_reached(direction: Vector2) -> void:
	var move_speed = 5.0  # Adjust the speed of the camera movement
	print("direction")
	print(direction)
	if direction == Vector2.LEFT:
		position.x -= move_speed
	elif direction == Vector2.RIGHT:
		position.x += move_speed
	elif direction == Vector2.UP:
		position.y -= move_speed
	elif direction == Vector2.DOWN:
		position.y += move_speed
