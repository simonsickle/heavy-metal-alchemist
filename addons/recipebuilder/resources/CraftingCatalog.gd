extends Resource

class_name CraftingCatalog

@export var items: Dictionary = {}

func get_unlocked_items() -> Array[CraftingItemResource]:
	var crafting_items: Array[CraftingItemResource] = []
	for entry_key in items.keys():
		var entry = items[entry_key]
		if entry.item.unlocked or entry.ingredients.size() == 0:
			crafting_items.append(entry.item)
	return crafting_items


func get_crafting_items() -> Array[CraftingItemResource]:
	var crafting_items: Array[CraftingItemResource] = []
	for row in items:
		crafting_items.append(row.item)
	return crafting_items


func get_item_ingredients(item_name: String) -> Array[CraftingItemResource]:
	return items[item_name].ingredients


func get_item(item_name: String) -> CraftingItemResource:
	if items.has(item_name):
		return items[item_name].item
	return null


func add_item(crafting_item: CraftingItemResource) -> void:
	if items.has(crafting_item.label):
		printerr("ERROR: Crafting catalog already has item named ", crafting_item.label)
		return
	
	items[crafting_item.label] = {
		item = crafting_item,
		ingredients = [],
	}


func add_ingredient(item_name: String, ingredient_name: String) -> void:
	items[item_name].ingredients.append(ingredient_name)

func unlock_item(item_name: String) -> CraftingItemResource:
	var item = items[item_name].item
	item.unlocked = true
	return item

func check_recipe_and_unlock(ingredients: Array[String]) -> CraftingItemResource:
	if ingredients.size() == 0: return null
	
	for entry_key in items.keys():
		var entry = items[entry_key]
		## No basic items
		if entry.ingredients.size() == 0: continue
		## No match if ingredients are different size
		if entry.ingredients.size() != ingredients.size(): continue
		## No already unlocked items
		if entry.item.unlocked: continue
		
		var matches = true
		for ingredient in ingredients:
			matches = matches and entry.ingredients.has(ingredient)
		
		if matches:
			entry.item.unlocked = true
			return entry.item
	return null
