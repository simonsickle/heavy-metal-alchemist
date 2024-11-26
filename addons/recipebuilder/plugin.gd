@tool
extends EditorPlugin

var MainPanel := preload("res://addons/recipebuilder/main_panel.tscn")
var editor_view_instance = null

func _enter_tree() -> void:
	editor_view_instance = MainPanel.instantiate()
	editor_view_instance.plugin = self
	editor_view_instance.hide()
	
	get_editor_interface().get_editor_main_screen().add_child(editor_view_instance)
	_make_visible(false)

func _exit_tree() -> void:
	if editor_view_instance:
		editor_view_instance.queue_free()

func _make_visible(visible: bool) -> void:
	if editor_view_instance:
		editor_view_instance.visible = visible


func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "Recipe Editor"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("GraphNode", "EditorIcons")
	
#func _edit(object: Object) -> void:
	#if not object:
		#return
	#_make_visible(true)

func _handles(object) -> bool:
	return object is GraphData
	
func _save_external_data() -> void:
	editor_view_instance.save_current_file()
