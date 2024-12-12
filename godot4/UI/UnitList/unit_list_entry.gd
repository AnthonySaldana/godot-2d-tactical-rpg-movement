extends HBoxContainer

@onready var name_label: Label = $NameLabel
@onready var health_bar: ProgressBar = $HealthBar

var _unit: Unit

func setup(unit: Unit) -> void:
	_unit = unit
	name_label.text = unit.unit_name
	update_health()
	
	# Connect to unit signals
	unit.damage_taken.connect(_on_unit_health_changed)
	unit.healed.connect(_on_unit_health_changed)
	unit.unit_defeated.connect(_on_unit_defeated)

func update_health() -> void:
	health_bar.max_value = _unit.scaled_max_health
	health_bar.value = _unit.current_health

func _on_unit_health_changed(_amount) -> void:
	update_health()

func _on_unit_defeated() -> void:
	queue_free()
