extends Control

const MAX_SLOTS = 20  # Can be modified based on character stats later
var inventory: Array = []
var is_open := false

@onready var grid_container = $Background/TabContainer/Inventory/GridContainer

func _ready() -> void:
	hide()
	_setup_inventory_slots()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):  # Make sure to add this input mapping
		toggle_inventory()

func toggle_inventory() -> void:
	is_open = !is_open
	if is_open:
		show()
	else:
		hide()

func _setup_inventory_slots() -> void:
	# Create initial inventory slots
	for i in range(MAX_SLOTS):
		var slot = preload("res://UI/Inventory/InventorySlot.tscn").instantiate()
		grid_container.add_child(slot)
		inventory.append(null)  # null represents empty slot

func add_item(item) -> bool:
	# Find first empty slot
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			grid_container.get_child(i).set_item(item)
			return true
	return false  # Inventory is full

func remove_item(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < inventory.size():
		inventory[slot_index] = null
		grid_container.get_child(slot_index).clear_item()
