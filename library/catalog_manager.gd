extends Node

signal new_item_unlocked(item: CraftingItemResource)
signal data_changed

const SAVE_GAME_FILE = "user://hma-save.tres"

@export var items: Array[CraftingItemResource] = []

var _catalog: CraftingCatalog
var _game_save: GameSave

func _ready() -> void:
	## Create the initial items
	_init_catalog()
	
	## Save game progress
	_handle_save_restore()

func _init_catalog() -> void:
	var data = ResourceLoader.load("res://library/catalog.tres")
	_catalog = data.crafting_catalog
	
	## Handle the initial unlocked items to insure order remains the same between saves
	items.append_array(_catalog.get_unlocked_items())


func _handle_save_restore() -> void:
	var game_save = ResourceLoader.load(SAVE_GAME_FILE)
	
	if not game_save or game_save is not GameSave:
		_game_save = GameSave.new()
		_game_save.unlocked_items = {}
	else:
		_game_save = game_save as GameSave

func can_resume() -> bool:
	return _game_save.unlocked_items.keys().size() > 0

func resume_game() -> void:
	for key in _game_save.unlocked_items.keys():
		var unlocked_from_save = _catalog.unlock_item(key)
		## Don't duplicate entries
		if items.has(unlocked_from_save): continue
		
		items.append(unlocked_from_save)


func reset_game_state() -> void:
	_game_save = GameSave.new()
	_game_save.unlocked_items = {}
	var err = ResourceSaver.save(GameSave.new(), SAVE_GAME_FILE)
	if err != OK:
		printerr("Could not reset game save: ", err)

	items.clear()
	_init_catalog()


func _save_game() -> void:
	for item in items:
		if _game_save.unlocked_items.has(item.label): continue
		
		_game_save.unlocked_items[item.label] = {
			unlocked_at = Time.get_time_string_from_system(),
		}
	
	var err = ResourceSaver.save(_game_save, SAVE_GAME_FILE)
	if err != OK:
		printerr("Error Saving: ", err)


func check_recipe(ingredients: Array[String]) -> bool:
	var unlocked = _catalog.check_recipe_and_unlock(ingredients)
	
	if unlocked:
		items.append(unlocked)
		_game_save.unlocked_items[unlocked.label] = {
			unlocked_at = Time.get_time_string_from_system(),
		}
		_save_game()
		new_item_unlocked.emit(unlocked)
		return true
	
	return false

func progress_label() -> String:
	return "%s of %s unlocked" % [items.size(), _catalog.items.size()]
