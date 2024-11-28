extends Control

@onready var transition_manager := $TransitionManager

@onready var catalog := $Catalog
@onready var first_item := $FirstItem
@onready var second_item := $SecondItem
@onready var combine_button := $CombineButton
@onready var progress_label := $ProgressLabel
@onready var music_toggle := $HBoxContainer/MusicToggle
@onready var audio_player := $AudioStreamPlayer
@onready var pause_menu := $PauseMenu

func _ready() -> void:
	transition_manager.fade_in()
	combine_button.pressed.connect(_do_combine)
	combine_button.visible = false
	
	progress_label.text = CatalogManager.progress_label()
	
	CatalogManager.new_item_unlocked.connect(_on_new_item_unlocked)
	
	music_toggle.pressed.connect(_on_music_toggled)
	
	pause_menu.pause_state_changed.connect(_on_pause_state_changed)


func _process(delta: float) -> void:
	combine_button.visible = first_item.item and second_item.item

func _on_pause_state_changed(paused: bool) -> void:
	if not paused:
		transition_manager.fade_in()

func _on_music_toggled() -> void:
	var should_play_music = not audio_player.playing
	
	if should_play_music:
		music_toggle.texture_normal = load("res://art/ui/volume_on.svg")
	else:
		music_toggle.texture_normal = load("res://art/ui/volume_off.svg")
	
	audio_player.playing = should_play_music


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
