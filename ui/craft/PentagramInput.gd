@tool
extends Control

@onready var BackgroundImg: TextureRect = $BackgroundImg
@onready var center_point := $CenterPoint

@onready var drop_points = [
	$DropPoint1,
	$DropPoint2,
	$DropPoint3,
	$DropPoint4,
	$DropPoint5,
	$CenterPoint,
]

# Positions relative to the pentagram's original resolution
@export var drop_point_offsets: Array[Vector2] = [
	Vector2(0.738, 0.09),
	Vector2(0.878, 0.532),
	Vector2(0.452, 0.87),
	Vector2(0.024, 0.538),
	Vector2(0.16, 0.094),
	Vector2(0.452, 0.5),
]:
	set(new_offsets):
		drop_point_offsets = new_offsets
		if self.is_node_ready(): _configure_drop_point_locations()


func _process(delta: float) -> void:
	_resize_view_with_image()
	_configure_drop_point_locations()


func _resize_view_with_image() -> void:
	var viewport_size = get_viewport_rect().size
	
	var x = viewport_size.x * .5 ### 50% of the width
	var y = viewport_size.y * .8 ### Or 80% of the height
	
	if x < y:
		BackgroundImg.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	else:
		BackgroundImg.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	
	## View should be the size of the smallest size
	var smallest_side = min(x,y)
	var normalized_size = Vector2(smallest_side, smallest_side)
	self.size = normalized_size
	BackgroundImg.size = normalized_size
	
	if not Engine.is_editor_hint():
		## Center in view, but not in the engine view because it breaks the engine previews
		var new_pos = Vector2((x - smallest_side) / 2, (viewport_size.y - smallest_side) / 2)
		set_global_position(new_pos)

func _configure_drop_point_locations() -> void:
	var image_rect = BackgroundImg.get_rect()
	var image_scale = image_rect.size / Vector2(666, 666)
	
	for idx in range(drop_points.size()):
		var drop_point = drop_points[idx]
		var offset = drop_point_offsets[idx]
		
		drop_point.scale = image_scale
		drop_point.position = image_rect.position + offset * image_rect.size

func begin_ritual() -> void:
	var recipe_items: Array[String] = []
	
	for idx in range(drop_points.size() - 1):
		var drop_point = drop_points[idx]
		
		## If this item slot has something we need to grab the label and burn the item one by one
		if drop_point.item:
			recipe_items.append(drop_point.item.label)
			await drop_point.burn_item()

	var unlocked = CatalogManager.check_recipe(recipe_items)
	
	## We unlocked an item, show the sweet animation that we created something
	if unlocked:
		center_point.item = unlocked
		await center_point.summon_item()
		await get_tree().create_timer(3).timeout
		center_point.burn_item()
	
	if not unlocked:
		ToastParty.show({
			"text": "Hmm... That didn't work.",
			"bgcolor": Color(0, 0, 0, 0.6),
			"color": Color(1, 1, 1, 1),
			"gravity": "bottom",
			"direction": "center",
		})

func has_item_inputs() -> bool:
	var slots_with_item = 0
	for idx in range(drop_points.size() - 1):
		if drop_points[idx].item: slots_with_item += 1
	
	return slots_with_item >= 2
