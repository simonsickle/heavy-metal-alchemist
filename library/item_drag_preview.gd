extends Control

@export var texture: Texture2D

func _ready() -> void:
	$TextureRect.texture = texture
