extends Resource
class_name Recipe

@export var first_ingredient: Item
@export var second_ingredient: Item
@export var creates: Item

func matches(item1: Item, item2: Item) -> bool:
	return (first_ingredient == item1 && second_ingredient == item2) || (first_ingredient == item2 && second_ingredient == item1)
