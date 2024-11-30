extends Control

var ItemSlotView = preload("res://library/item_slot_ui.tscn")

@onready var item_container := $ScrollContainer/GridContainer

func _ready() -> void:
	CatalogManager.new_item_unlocked.connect(_on_new_item_unlocked)
	CatalogManager.data_changed.connect(_on_catalog_data_changed)
	for item in CatalogManager.items:
		_create_or_update_item(item)

func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	
	var normalized_size = Vector2(viewport_size.x * .4, viewport_size.y * .75)
	self.size = normalized_size
	
	## Center the view in the right side
	var x_coord = viewport_size.x - normalized_size.x - ((viewport_size.x * .5 - viewport_size.x * .4) / 2 )
	var y_coord = (viewport_size.y - normalized_size.y) / 2
	self.global_position = Vector2(x_coord, y_coord)

func _on_catalog_data_changed() -> void:
	for item in CatalogManager.items:
		_create_or_update_item(item)


func _on_new_item_unlocked(item: CraftingItemResource) -> void:
	var item_slot: ItemSlotUi = _create_or_update_item(item)
	item_slot.play_shimmer_animation()


func _create_or_update_item(item: CraftingItemResource) -> ItemSlotUi:
	var existing_node: ItemSlotUi = item_container.get_node(item.label)
	
	if existing_node:
		existing_node.name = item.label
		existing_node.item = item
		return existing_node

	var item_slot: ItemSlotUi = ItemSlotView.instantiate()
	item_slot.name = item.label
	item_slot.item = item
	
	item_container.add_child(item_slot)
	return item_slot
