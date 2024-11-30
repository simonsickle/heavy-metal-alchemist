extends Control
class_name ItemSlotUi

@export var item: CraftingItemResource = null

@onready var icon_image := $Background/Icon
@onready var label := $Label

var ItemDragPreview = preload("res://library/item_drag_preview.tscn")
var ShimmerMaterial = preload("res://shaders/shimmer.material")

# Called whenever the item is clicked on the UI
signal on_item_click(item: CraftingItemResource)

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = ItemDragPreview.instantiate()
	preview.texture = item.icon
	set_drag_preview(preview)
	return item

func _process(delta: float) -> void:
	if item != null:
		icon_image.texture = item.icon
		label.text = item.label
	else:
		icon_image.texture = null
		label.text = ""

func play_shimmer_animation() -> void:
	icon_image.material = ShimmerMaterial
	await get_tree().create_timer(4).timeout
	icon_image.material = null
