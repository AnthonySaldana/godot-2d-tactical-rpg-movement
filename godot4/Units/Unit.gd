## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
@tool
class_name Unit
extends Path2D

@onready var _animated_sprite: AnimatedSprite2D = $PathFollow2D/AnimatedSprite2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished
## Add these signals at the top of the Unit class
signal damage_taken(amount)
signal unit_defeated
signal healed(amount)
## Shared resource of type Grid, used to calculate map coordinates.
@export var grid: Resource
## Designate current unit as enemy
@export var is_enemy: bool
## Designate the current unit in a "wait" state
@export var is_wait := false
## Distance to which the unit can walk in cells.
@export var move_range := 6
## The unit's move speed when it's moving along a path.
@export var move_speed := 600.0
## The distance the unit can attack from their current position
@export var attack_range := 0
## The unit's attack power
@export var attack_power := 10
## The unit's maximum health
@export var max_health := 100
## The unit's current level
@export var unit_level := 1

var scaled_max_health := max_health

## Current health of the unit.
var current_health: int:
	set(value):
		current_health = value
		update_health_bar()

## Texture representing the unit.
@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			# This will resume execution after this node's _ready()
			await ready
		_sprite.texture = value
## Offset to apply to the `skin` sprite in pixels.
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO:
	set(value):
		# When changing the cell's value, we don't want to allow coordinates outside
		#	the grid, so we clamp them
		cell = grid.grid_clamp(value)
## Toggles the "selected" animation on the unit.
var is_selected := false:
	set(value):
		is_selected = value
		if is_selected:
			_anim_player.play("selected")
		else:
			_anim_player.play("idle")

var _is_walking := false:
	set(value):
		_is_walking = value
		set_process(_is_walking)

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var _health_bar: ProgressBar = $HealthBar 

# Method to scale health based on level or difficulty.
func scale_health(level: int) -> void:
	scaled_max_health = max_health + (level * 20)  # Example scaling logic
	current_health = scaled_max_health  # Reset current health to max when scaling
	update_health_bar()  # Update health bar after scaling


	## Update the health bar when health changes
func update_health_bar() -> void:
	print("current health from bar: ", current_health)
	_health_bar.value = (float(current_health) / scaled_max_health) * 100
	_health_bar.visible = current_health < scaled_max_health

	print("scaled max health: ", scaled_max_health)
	print("health bar value: ", _health_bar.value)
	
	if current_health <= 0:
		emit_signal("unit_defeated")


func _ready() -> void:
	set_process(false)
	_path_follow.rotates = false
	
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	
	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()

	# Scale health based on level or difficulty.
	scale_health(unit_level)
	_animated_sprite.play("idle")
	
	# Only show health bar when damaged
	_health_bar.visible = current_health < scaled_max_health


func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta
	
	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		# Setting this value to 0.0 causes a Zero Length Interval error
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		# update_health_bar() 


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true

## Take damage and update health
func take_damage(damage: int) -> void:
	current_health = max(0, current_health - damage)
	update_health_bar()
	
	# Play hit animation or effect if you have one
	if _animated_sprite:
		_animated_sprite.play("hit")
		await _animated_sprite.animation_finished
		_animated_sprite.play("idle")
	
	# Emit a signal that damage was taken (useful for UI updates)
	# You'll need to declare this signal at the top of the file
	emit_signal("damage_taken", damage)

## Add a flash effect when taking damage
func _flash_damage() -> void:
	if not _animated_sprite:
		return
	
	var tween = create_tween()
	tween.tween_property(_animated_sprite, "modulate", Color.RED, 0.3)
	tween.tween_property(_animated_sprite, "modulate", Color.WHITE, 0.3)

func heal(amount: int) -> void:
	print("before healing: ", current_health)
	print("max health: ", scaled_max_health)
	print("Healing unit for ", amount, " health")
	current_health = min(scaled_max_health, current_health + amount)
	await get_tree().create_timer(0.2).timeout
	print("after healing: ", current_health)
	update_health_bar()
	emit_signal("healed", amount)
