extends Control

@export var drop_item_allowed: bool = true
@export var auto_update_item_ui: bool = true
@export var item: CraftingItemResource = null

@onready var item_icon := $ItemIcon
@onready var animation_player := $AnimationPlayer

func _ready() -> void:
	$Panel.visible = Engine.is_editor_hint()
	_update_item_info()

func _process(delta: float) -> void:
	if auto_update_item_ui: _update_item_info()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if item: burn_item()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return drop_item_allowed and data is CraftingItemResource and !animation_player.is_playing()

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is CraftingItemResource:
		item = data

func _update_item_info():
	if item:
		item_icon.texture = item.icon
	else:
		item_icon.texture = null

func summon_item() -> Signal:
	_update_item_info()
	
	if not animation_player.is_playing():
		animation_player.play("summon_icon")
	
	return animation_player.animation_finished

func burn_item() -> Signal:
	_update_item_info()
	
	if not animation_player.is_playing():
		animation_player.play("burn_icon")
	
	return animation_player.animation_finished
