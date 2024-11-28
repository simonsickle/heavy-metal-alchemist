extends Control

@onready var TransitionManager := $TransitionManager
@onready var ResumeButton := $VBoxContainer/ResumeGameBtn
@onready var NewGameButton := $VBoxContainer/NewGameBtn
@onready var CreditsButton := $VBoxContainer/CreditsButton
@onready var ExitGameButton := $VBoxContainer/ExitGameBtn

func _ready() -> void:
	TransitionManager.fade_in()
	
	ResumeButton.pressed.connect(_on_resume_game)
	NewGameButton.pressed.connect(_on_new_game)
	CreditsButton.pressed.connect(_show_credits)
	ExitGameButton.pressed.connect(_on_exit_game)
	
	ResumeButton.visible = CatalogManager.can_resume()

func _on_resume_game() -> void:
	CatalogManager.resume_game()
	await TransitionManager.fade_out()
	get_tree().change_scene_to_file("res://crafting_screen.tscn")

func _on_new_game() -> void:
	CatalogManager.reset_game_state()
	await TransitionManager.fade_out()
	get_tree().change_scene_to_file("res://crafting_screen.tscn")

func _show_credits() -> void:
	await TransitionManager.fade_out()
	get_tree().change_scene_to_file("res://credits/GodotCredits.tscn")

func _on_exit_game() -> void:
	get_tree().quit()
