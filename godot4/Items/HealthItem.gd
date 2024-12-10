class_name HealthItem
extends Node2D

@export var healing_amount: int = 20
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("healing_items")
	animated_sprite.play("idle")  # Your default animation

func collect() -> void:
	animated_sprite.play("collect")  # Optional collection animation
	# Could emit signals or play sounds here 
