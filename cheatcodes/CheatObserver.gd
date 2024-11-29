extends Node

var input_log: Array[String] = []

var cheat_codes = {
	konami = {
		pattern = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right"],
		on_unlock = _on_konami_code,
	}
}

func _ready() -> void:
	input_log.resize(10)

func _input(event: InputEvent) -> void:
	var valid_input = false
	
	if event.is_action_pressed("ui_up"):
		input_log.append("Up")
		valid_input = true
	elif event.is_action_pressed("ui_down"):
		input_log.append("Down")
		valid_input = true
	elif event.is_action_pressed("ui_left"):
		input_log.append("Left")
		valid_input = true
	elif event.is_action_pressed("ui_right"):
		input_log.append("Right")
		valid_input = true
	
	if not valid_input: return
	
	for key in cheat_codes.keys():
		var cheat_code = cheat_codes[key]
		
		## Only check the last few inputs, but don't allow negative indexes
		var from_idx = max(input_log.size() - cheat_code.pattern.size(), 0)
		## Slice the input array to check the last input. This allows restart right after failure.
		var to_compare = input_log.slice(from_idx, input_log.size())
		
		if to_compare == cheat_code.pattern:
			cheat_code.on_unlock.call()

func _on_konami_code() -> void:
	CatalogManager.unlock_item("T-Shirt")
