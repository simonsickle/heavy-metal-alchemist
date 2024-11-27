@tool
extends GraphNode

class_name CraftingItemNode

signal node_changed

@onready var name_input: LineEdit = $NameTextInput
@onready var icon_selector: EditorResourcePicker = $HBoxContainer/IconTexturePicker

@export var restore_label: String
@export var restore_icon_texture: Texture2D

func get_label() -> String:
	print("Getting name: ", name_input.text)
	return name_input.text

func get_icon_texture() -> Texture2D:
	print("Getting icon: ", icon_selector.edited_resource)
	return icon_selector.edited_resource

func _ready() -> void:
	if restore_label:
		name_input.text = restore_label
	
	if restore_icon_texture:
		icon_selector.edited_resource = restore_icon_texture
	
	name_input.text_changed.connect(_on_name_changed)
	icon_selector.resource_changed.connect(_on_resource_changed)
	
func _on_name_changed(text: String) -> void:
	node_changed.emit()

func _on_resource_changed(resouce: Resource) -> void:
	node_changed.emit()

func _on_unlocked_toggle(toggled_on: bool) -> void:
	node_changed.emit()
