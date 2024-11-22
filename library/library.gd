extends Resource
class_name Library

@export var items: Array[Item] = []

func _init() -> void:
	## Load the entire item catalog into the library
	## TODO: we should look at game save state and set unlocked here too
	for resource in DirAccess.get_files_at("res://library/items/"):
		var item := load("res://library/items/%s" % resource)
		items.append(item)

func unlock_item(to_unlock: Item) -> void:
	for item in items:
		if item.name == to_unlock.name:
			item.unlocked = true
