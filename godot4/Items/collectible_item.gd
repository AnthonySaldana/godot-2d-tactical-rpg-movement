extends Node2D

@export var item_data: ItemData

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	if item_data:
		# Create a SpriteFrames resource
		#var frames = SpriteFrames.new()
		#frames.add_animation("default")
		#frames.add_frame("default", item_data.texture)
		#sprite.sprite_frames = frames
		sprite.play("default")
