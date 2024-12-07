## Represents an enemy unit that extends the base Unit class.
## Adds enemy-specific behavior and disables player input.
class_name Enemy
extends Unit

func _ready() -> void:
	super()
	is_enemy = true # Ensure this enemy unit is marked as an enemy
	
func _unhandled_input(_event: InputEvent) -> void:
	# Disable player input handling for enemy units
	pass
