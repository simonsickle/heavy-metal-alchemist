extends Control

@onready var catalog := $Catalog
@onready var first_item := $FirstItem
@onready var second_item := $SecondItem
@onready var combine_button := $CombineButton

var recipes := Recipes.new()

func _ready() -> void:
	catalog.connect("on_catalog_item_click", _on_catalog_item_select)
	combine_button.connect("pressed", _do_combine)
	combine_button.visible = false

func _on_catalog_item_select(item: Item) -> void:
	if first_item.item == null:
		first_item.item = item
	elif second_item.item == null:
		second_item.item = item
	else:
		print("Shitter's full")

	## Show the combine button if both recipe items are full
	if first_item.item != null && second_item.item != null:
		combine_button.visible = true

func  _do_combine() -> void:
	var created := recipes.does_recipe_match_any(first_item.item, second_item.item)
	
	if created != null:
		catalog.unlock_item(created)
	
	## Reset the entries
	first_item.item = null
	second_item.item = null
