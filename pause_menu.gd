extends Control

signal pause_state_changed(paused: bool)

@onready var TransitionManager := $TransitionManager

@onready var ResumeBtn := $VBoxContainer/ResumeBtn
@onready var ExitBtn := $VBoxContainer/ExitButton

func _ready() -> void:
	TransitionManager.fade_in()
	
	ResumeBtn.pressed.connect(_on_resume_pressed)
	ExitBtn.pressed.connect(_on_exit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		_pause_or_unpause()

func _on_resume_pressed() -> void:
	_pause_or_unpause()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _pause_or_unpause() -> void:
	var should_pause = not self.visible
	
	get_tree().paused = should_pause
	
	if should_pause:
		TransitionManager.fade_in()
		self.visible = true
		pause_state_changed.emit(true)
	else:
		await TransitionManager.fade_out()
		self.visible = false
		pause_state_changed.emit(false)
