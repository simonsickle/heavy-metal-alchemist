extends Control

@onready var background: ColorRect = $FadeRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	## insure that the color rect is hidden at first
	self.visible = false


func fade_out() -> Signal:
	## Force the background to be transparent
	background.self_modulate = Color(0,0,0,0)
	self.visible = true
	
	animation_player.play("fade_out")
	return get_tree().create_timer(0.5).timeout


func fade_in() -> void:
	## Force the background to be opaque
	background.self_modulate = Color(0,0,0,1)
	self.visible = true
	
	animation_player.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
	self.visible = false
