extends Control

@onready var catalog := $Catalog
@onready var first_item := $FirstItem
@onready var second_item := $SecondItem
@onready var combine_button := $CombineButton
@onready var progress_label := $ProgressLabel

func _ready() -> void:
	combine_button.pressed.connect(_do_combine)
	combine_button.visible = false
	progress_label.text = CatalogManager.progress_label()
	CatalogManager.new_item_unlocked.connect(_on_new_item_unlocked)


func _process(delta: float) -> void:
	combine_button.visible = first_item.item and second_item.item

func _on_new_item_unlocked(item: CraftingItemResource) -> void:
	progress_label.text = CatalogManager.progress_label()
	
	ToastParty.show({
		"text": "%s Unlocked!" % item.label,
		"bgcolor": Color(0, 0, 0, 0.6),
		"color": Color(1, 1, 1, 1),
		"gravity": "bottom",
		"direction": "center",
	})


func  _do_combine() -> void:
	var unlocked = CatalogManager.check_recipe([first_item.item.label, second_item.item.label])
	
	if not unlocked:
		ToastParty.show({
		"text": "Hmm... That didn't work.",
		"bgcolor": Color(0, 0, 0, 0.6),
		"color": Color(1, 1, 1, 1),
		"gravity": "bottom",
		"direction": "center",
	})
	
	## Reset the entries
	first_item.item = null
	second_item.item = null
