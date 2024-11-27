extends Panel
class_name ItemInputSlot

@export var item: CraftingItemResource = null

@onready var icon_image := $Icon
@onready var label := $Label

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is CraftingItemResource

func _drop_data(at_position: Vector2, data: Variant) -> void:
	item = data as CraftingItemResource

func _process(delta: float) -> void:
	if item != null:
		icon_image.texture = item.icon
		label.text = item.label
	else:
		icon_image.texture = null
		label.text = ""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			item = null
