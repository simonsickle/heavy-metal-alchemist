extends Control

@onready var transition_manager := $TransitionManager

@onready var pentagram_input := $PentagramInput
@onready var combine_button := $CombineButton

@onready var catalog := $Catalog

@onready var progress_label := $ProgressLabel
@onready var audio_player := $AudioStreamPlayer
@onready var pause_menu := $PauseMenu

func _ready() -> void:
	transition_manager.fade_in()
	combine_button.pressed.connect(_do_combine)
	combine_button.visible = false
	
	progress_label.text = CatalogManager.progress_label()
	
	CatalogManager.new_item_unlocked.connect(_on_new_item_unlocked)
	
	pause_menu.pause_state_changed.connect(_on_pause_state_changed)


func _process(delta: float) -> void:
	combine_button.visible = pentagram_input.has_item_inputs()
	progress_label.text = CatalogManager.progress_label()
	
func _on_pause_state_changed(paused: bool) -> void:
	if not paused:
		transition_manager.fade_in()

func _on_music_toggled() -> void:
	audio_player.stream_paused = not audio_player.stream_paused


func _on_new_item_unlocked(item: CraftingItemResource) -> void:
	progress_label.text = CatalogManager.progress_label()
	
	if item.label == "T-Shirt":
		ToastParty.show({
			"text": "I entered the Konami code and all I got was this T-Shirt!",
			"bgcolor": Color(0, 0, 0, 0.6),
			"color": Color(1, 1, 1, 1),
			"gravity": "bottom",
			"direction": "center",
		})
		return
	
	ToastParty.show({
		"text": "%s Unlocked!" % item.label,
		"bgcolor": Color(0, 0, 0, 0.6),
		"color": Color(1, 1, 1, 1),
		"gravity": "bottom",
		"direction": "center",
	})


func  _do_combine() -> void:
	pentagram_input.begin_ritual()
