@tool
extends Control

@onready var file_menu := $VBox/MenuBar/File
@onready var open_file_dialog: FileDialog = $OpenFileDialog
@onready var save_file_dialog: FileDialog = $SaveAsFileDialog
@onready var files_list := $VBox/HBoxContainer/VBoxContainer/FilesList
@onready var add_element_btn := $VBox/HBoxContainer/VBoxContainer/AddElementBtn
@onready var graph: RecipeGraph = $VBox/HBoxContainer/Graph

var plugin: EditorPlugin

var open_buffers: Dictionary = {}
var current_file_path: String

func _ready() -> void:
	file_menu.connect("id_pressed", _on_file_menu_pressed)
	
	files_list.connect("file_selected", _open_list_file)
	add_element_btn.connect("pressed", _on_add_element_pressed)
	open_file_dialog.connect("file_selected", open_file)
	save_file_dialog.connect("file_selected", _on_save_file_selected)
	
	graph.connect("graph_modified", _on_graph_modified)

	## Open the default catalog file
	open_file("res://library/catalog.tres")

func _on_file_menu_pressed(id: int) -> void:
	match id:
		## New File
		1: save_file_dialog.popup_centered()
		## Save file
		2: _save_file(current_file_path, graph.save_data())
		## Open File
		3: open_file_dialog.popup_centered()
		## Create graph element
		4: _on_add_element_pressed()

func _on_add_element_pressed() -> void:
	graph.add_new_node()

func _on_cache_file_content_changed(path: String, new_content: String) -> void:
	if open_buffers.has(path):
		open_buffers[path].resource = ResourceLoader.load(path)
		graph.init_graph(open_buffers[path].resource)


func _on_graph_modified() -> void:
	open_buffers[current_file_path] = {
		resource = graph.save_data(),
	}
	
	files_list.mark_file_as_unsaved(current_file_path, true)

func new_file(path: String) -> void:
	if path == "":
		save_file_dialog.popup_centered()
		return
	
	if open_buffers.has(path):
		remove_file_from_open_buffers(path)
	
	## Create a blank graph since the file is new
	_save_file(path, GraphData.new())
	## Show the new file in the FS panel for easy finding by the user
	plugin.get_editor_interface().get_resource_filesystem().scan()


func _open_list_file(path: String) -> void:
	## Check if current file is not empty and save it before changing
	if current_file_path != "" and current_file_path != path:
		open_buffers[current_file_path] = { resource = graph.save_data() }
		open_file(path)


func open_file(path: String) -> void:
	var graph_data: GraphData
	if open_buffers.has(path):
		graph_data = open_buffers[path].resource as GraphData
	else:
		graph_data = ResourceLoader.load(path) as GraphData
		open_buffers[path] = {
			resource = graph_data,
		}
	
	files_list.files = open_buffers.keys()
	files_list.select_file(path)
	self.current_file_path = path
	show_file_in_filesystem(path)
	
	graph.init_graph(graph_data)

func remove_file_from_open_buffers(path: String) -> void:
	if not path in open_buffers.keys(): return

	var current_index = open_buffers.keys().find(current_file_path)

	open_buffers.erase(path)
	if open_buffers.size() == 0:
		self.current_file_path = ""
	else:
		current_index = clamp(current_index, 0, open_buffers.size() - 1)
		self.current_file_path = open_buffers.keys()[current_index]

	files_list.files = open_buffers.keys()


func _on_save_file_selected(path: String) -> void:
	_save_file(path, graph.save_data())
	remove_file_from_open_buffers("")
	open_file(path)


func save_current_file() -> void:
	## Don't show the save dialog if there isn't anything to save yet
	if graph.get_child_count() == 0: return
	
	_save_file(self.current_file_path, graph.save_data())


func _save_file(path: String, data: GraphData) -> void:
	if not files_list.is_file_unsaved(path): return

	if path == "":
		save_file_dialog.popup_centered()
		return
	
	open_buffers[path] = { resource = data }
	
	var error = ResourceSaver.save(data, path)
	if error == OK:
		files_list.mark_file_as_unsaved(path, false)
		var file_system: EditorFileSystem = plugin \
		.get_editor_interface() \
		.get_resource_filesystem()
		
		file_system.reimport_files([path])
		await get_tree().create_timer(0.2)
		print("Saved successfully")
	else:
		print("Error saving graph_data")


func show_file_in_filesystem(path: String) -> void:
	var file_system_dock: FileSystemDock = plugin \
		.get_editor_interface() \
		.get_file_system_dock()

	file_system_dock.navigate_to_path(path)
	
