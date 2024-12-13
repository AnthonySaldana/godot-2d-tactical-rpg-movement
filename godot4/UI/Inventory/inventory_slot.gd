extends Panel

var item = null

@onready var item_texture = $ItemTexture
@onready var item_count = $ItemCount

func set_item(new_item) -> void:
	item = new_item
	if item:
		item_texture.texture = item.texture
		if item.stackable:
			item_count.text = str(item.count)
			item_count.show()
		else:
			item_count.hide()
	update_appearance()

func clear_item() -> void:
	item = null
	item_texture.texture = null
	item_count.hide()
	update_appearance()

func update_appearance() -> void:
	if item:
		modulate = Color.WHITE
	else:
		modulate = Color(0.8, 0.8, 0.8, 1.0)
