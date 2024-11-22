extends Object
class_name Recipes

var recipes: Array[Recipe] = []

func _init() -> void:
	for resource in DirAccess.get_files_at("res://library/recipes/"):
		var recipe := load("res://library/recipes/%s" % resource) 
		recipes.append(recipe)

func does_recipe_match_any(item1: Item, item2: Item) -> Item:
	var matches := recipes.filter(func (recipe: Recipe): return recipe.matches(item1, item2))
	if matches.size() == 1:
		print("Created new item %s" % matches[0].creates)
		return matches[0].creates
	else:
		return null
