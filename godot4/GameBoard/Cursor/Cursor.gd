## Player-controlled cursor. Allows them to navigate the game grid, select units, and move them.
## Supports both keyboard and mouse (or touch) input.
@tool
class_name Cursor
extends Node2D

## Emitted when clicking on the currently hovered cell or when pressing "ui_accept".
signal accept_pressed(cell)
## Emitted when the cursor moved to a new cell.
signal moved(new_cell)

## Emitted when the cursor is near the edge of the screen.
signal edge_reached(direction)

## Grid resource, giving the node access to the grid size, and more.
@export var grid: Resource
## Time before the cursor can move again in seconds.
@export var ui_cooldown := 0.1

var is_mouse = false

## Coordinates of the current cell the cursor is hovering.
@export_group("Cursor")
@export var cell := Vector2.ZERO:
	set(value):
		# We first clamp the cell coordinates and ensure that we aren't
		#	trying to move outside the grid boundaries
		var new_cell: Vector2 = grid.grid_clamp(value)
		if new_cell.is_equal_approx(cell):
			return

		cell = new_cell
		# If we move to a new cell, we update the cursor's position, emit
		#	a signal, and start the cooldown timer that will limit the rate
		#	at which the cursor moves when we keep the direction key held
		#	down
		position = grid.calculate_map_position(cell)
		emit_signal("moved", cell)
		_timer.start()

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.wait_time = ui_cooldown
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

func _unhandled_input(event: InputEvent) -> void:
	# Navigating cells with the mouse.
	if event is InputEventMouseMotion:
		#cell = grid.calculate_grid_coordinates(event.position)
		is_mouse = true
	# Trying to select something in a cell.
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)
		get_viewport().set_input_as_handled()

	var should_move := event.is_pressed() 
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	if not should_move:
		return

	# Moves the cursor by one grid cell.
	if event.is_action("ui_right"):
		cell += Vector2.RIGHT
		is_mouse = false
	elif event.is_action("ui_up"):
		cell += Vector2.UP
		is_mouse = false
	elif event.is_action("ui_left"):
		cell += Vector2.LEFT
		is_mouse = false
	elif event.is_action("ui_down"):
		cell += Vector2.DOWN
		is_mouse = false


func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.ALICE_BLUE, false, 2.0)

# ... existing code ...

func _process(_delta: float) -> void:
	if(is_mouse):
		var grid_coords = grid.calculate_grid_coordinates(get_global_mouse_position())
		if(cell != grid_coords):
			cell = grid_coords

		# Check if the cursor is near the edge of the screen
		var viewport_size = get_viewport().get_size()
		var mouse_pos = get_viewport().get_mouse_position()
		var edge_threshold = -5  # Pixels from edge to trigger camera movement
		
		# Only emit edge signals when mouse is actually near viewport edges
		if mouse_pos.x < edge_threshold:
			emit_signal("edge_reached", Vector2.LEFT)
		elif mouse_pos.x > viewport_size.x - edge_threshold:
			emit_signal("edge_reached", Vector2.RIGHT)
		elif mouse_pos.y < edge_threshold:
			emit_signal("edge_reached", Vector2.UP) 
		elif mouse_pos.y > viewport_size.y - edge_threshold:
			emit_signal("edge_reached", Vector2.DOWN)
