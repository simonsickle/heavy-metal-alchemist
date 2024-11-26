extends Resource

class_name CraftingCatalog

@export var items: Array[CraftingItemResource]
@export var recipes: Array[CraftingRecipeResource]

func check_recipe(first: CraftingItemResource, second: CraftingItemResource) -> CraftingItemResource:
	## This expects that recipes are only 2 items... FIXME
	for recipe in recipes:
		if recipe.inputs.has(first) and recipe.inputs.has(second):
			return recipe.output
	
	## This doesn't make anything, try again!
	return null

## Return an array of items that should be unlocked by default since they have no
## recipe to create them.
func get_default_unlocked() -> Array[CraftingItemResource]:
	var unlocked_items = items
	
	## Loop through recipes to remove anything that is listed as an output
	for recipe in recipes:
		var idx = unlocked_items.find(recipe.output)
		if idx > 0 and idx < unlocked_items.size():
			unlocked_items.remove_at(idx)
	
	return unlocked_items
