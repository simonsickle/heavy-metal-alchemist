extends Control

@onready var item_container := $ScrollContainer/GridContainer

var library : Library = Library.new()

signal on_catalog_item_click(item: Item)

func unlock_item(item: Item) -> void:
	library.unlock_item(item)
	_create_and_add_item(item)

func _ready() -> void:
	for item in library.items:
		if item.unlocked:
			_create_and_add_item(item)

func _create_and_add_item(item: Item) -> void:
	var item_slot := preload("res://library/item_slot_ui.tscn").instantiate()
	item_slot.item = item
	item_slot.connect("on_item_click", _on_catalog_item_click)
	item_container.add_child(item_slot)

func _on_catalog_item_click(item: Item) -> void:
	emit_signal("on_catalog_item_click", item)
