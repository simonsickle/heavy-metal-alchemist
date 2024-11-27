extends Control

var ItemSlotView = preload("res://library/item_slot_ui.tscn")

@onready var item_container := $ScrollContainer/GridContainer

func _ready() -> void:
	CatalogManager.new_item_unlocked.connect(_on_new_item_unlocked)
	CatalogManager.data_changed.connect(_on_catalog_data_changed)
	for item in CatalogManager.items:
		_create_or_update_item(item)


func _on_catalog_data_changed() -> void:
	for item in CatalogManager.items:
		_create_or_update_item(item)


func _on_new_item_unlocked(item: CraftingItemResource) -> void:
	_create_or_update_item(item)


func _create_or_update_item(item: CraftingItemResource) -> void:
	var existing_node: ItemSlotUi = item_container.get_node(item.label)
	
	if existing_node:
		existing_node.name = item.label
		existing_node.item = item
		return

	var item_slot: ItemSlotUi = ItemSlotView.instantiate()
	item_slot.name = item.label
	item_slot.item = item
	
	item_container.add_child(item_slot)
