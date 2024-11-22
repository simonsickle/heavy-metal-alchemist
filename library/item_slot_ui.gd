extends Panel
class_name ItemSlotUi

@export var item: Item = null

@onready var icon_image := $Icon
@onready var label := $Label

# Called whenever the item is clicked on the UI
signal on_item_click(item: Item)

func _process(delta: float) -> void:
	if item != null:
		icon_image.texture = item.texture
		label.text = item.name
	else:
		icon_image.texture = null
		label.text = ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("on_item_click", item)
