@tool
extends GraphNode

class_name CraftingItemNode

signal node_changed

@onready var name_input: LineEdit = $NameTextInput
@onready var icon_selector: EditorResourcePicker = $HBoxContainer/IconTexturePicker

var resource: CraftingItemResource

func _ready() -> void:
	if resource:
		name_input.text = resource.label
		icon_selector.edited_resource = resource.icon
		
		## Clear out the resource
		resource = null
	
	name_input.text_changed.connect(_on_name_changed)
	icon_selector.resource_changed.connect(_on_resource_changed)

func _on_name_changed(text: String) -> void:
	node_changed.emit()

func _on_resource_changed(resouce: Resource) -> void:
	node_changed.emit()

func _on_unlocked_toggle(toggled_on: bool) -> void:
	node_changed.emit()

func to_element_resource() -> CraftingItemResource:
	var item := CraftingItemResource.new()
	item.label = name_input.text
	item.icon = icon_selector.edited_resource
	return item
