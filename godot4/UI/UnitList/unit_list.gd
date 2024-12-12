extends Control

@onready var unit_list_container: MarginContainer = $MarginContainer
@onready var unit_list_box: BoxContainer = $MarginContainer/BoxContainer

func _ready() -> void:
	# Set up the anchors and margins for top-left positioning
	custom_minimum_size = Vector2(300, 0)  # Adjust width as needed
	anchors_preset = PRESET_TOP_LEFT
	offset_left = 10  # Adds some padding from the left edge
	offset_top = 10   # Adds some padding from the top edge
	
	await get_tree().create_timer(0.1).timeout
	update_unit_list()

func update_unit_list() -> void:
	# Verify unit_list_container exists before using it
	print("Preparing instance in unit list")
	if !is_instance_valid(unit_list_container):
		push_error("unit_list_container is null - make sure the MarginContainer node exists and has the correct path")
		return
		
	# Clear existing entries
	for child in unit_list_box.get_children():
		child.queue_free()
	
	# Get all units in the scene
	print("getting units from group")
	var units = get_tree().get_nodes_in_group("units")
	print("units in unitlistentryt")
	print(units)
	 
	# Create an entry for each unit
	for unit in units:
		var unit_entry = preload("res://UI/UnitList/UnitListEntry.tscn").instantiate()
		unit_list_box.add_child(unit_entry)
		unit_entry.setup(unit)
