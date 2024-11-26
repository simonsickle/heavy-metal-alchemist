@tool
extends GraphEdit

class_name RecipeGraph

signal graph_modified

var CraftingItemNodeResource := preload("res://addons/recipebuilder/components/graph/node/crafting_item_node.tscn")

func _ready() -> void:
	self.connect("connection_request", _on_connection_request)
	self.connect("disconnection_request", _on_disconnect_request)
	self.connect("delete_nodes_request", _on_delete_node_request)
	self.connect("end_node_move", _on_node_move_end)

func add_new_node() -> void:
	var new_node: CraftingItemNode = CraftingItemNodeResource.instantiate()
	
	# If there are children, we always want to add the next near the last created node
	var number_of_children = self.get_child_count()
	if number_of_children > 1:
		var last_child_pos := (self.get_children()[number_of_children - 1] as CraftingItemNode).position
		new_node.position_offset = Vector2(last_child_pos.x + 32, last_child_pos.y + 32)
	
	new_node.connect("node_changed", _on_node_changed)
	
	self.add_child(new_node, true)
	
	emit_signal("graph_modified")

func _on_delete_node_request(nodes: Array[StringName]) -> void:
	for node in nodes:
		var graph_node := self.get_node(NodePath(node))
		self.remove_child(graph_node)
		graph_node.queue_free()
	
	emit_signal("graph_modified")

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	self.connect_node(from_node, from_port, to_node, to_port)
	emit_signal("graph_modified")


func _on_disconnect_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	self.disconnect_node(from_node, from_port, to_node, to_port)
	emit_signal("graph_modified")

func _on_node_move_end() -> void:
	emit_signal("graph_modified")

func _on_node_changed() -> void:
	emit_signal("graph_modified")

func save_data() -> GraphData:
	var graph_data = GraphData.new()
	
	graph_data.crafting_catalog = CraftingCatalog.new()
	graph_data.crafting_catalog.recipes.append_array(_build_recipes())
	graph_data.crafting_catalog.items.append_array(_build_items_list())
	
	## For the restored connections to work we must convert the @ symbol to underscores
	for connection in self.get_connection_list():
		graph_data.connections.append({
			from_node = connection.from_node.replace("@", "_"),
			from_port = connection.from_port,
			to_node = connection.to_node.replace("@", "_"),
			to_port = connection.to_port,
		})
	
	## For the restored connections to work we must convert the @ symbol to underscores
	for node in self.get_children():
		if node is CraftingItemNode:
			var node_data = NodeData.new()
			node_data.name = node.name.replace("@", "_")
			node_data.offset = node.position_offset
			node_data.element = node.to_element_resource()
			graph_data.nodes.append(node_data)
	return graph_data


func _build_items_list() -> Array[CraftingItemResource]:
	var items: Array[CraftingItemResource]
	for node in self.get_children():
		if node is CraftingItemNode:
			items.append(node.to_element_resource())
	return items

func _build_recipes() -> Array[CraftingRecipeResource]:
	var recipes: Array[CraftingRecipeResource]
	var items_dict = {}
	
	for con in self.get_connection_list():
		var start: CraftingItemNode = get_node(NodePath(con.from_node))
		var end: CraftingItemNode = get_node(NodePath(con.to_node))
		
		var start_res = start.to_element_resource()
		var end_res = end.to_element_resource()
		
		if items_dict.has(end_res.label):
			items_dict[end_res.label].inputs.append(start_res)
		else:
			items_dict[end_res.label] = {
				output = end_res,
				inputs = [start_res]
			}
	
	for key in items_dict.keys():
		var recipe: CraftingRecipeResource = CraftingRecipeResource.new()
		recipe.inputs.append_array(items_dict[key].inputs)
		recipe.output = items_dict[key].output
		
		recipes.append(recipe)
	
	return recipes


func init_graph(graph_data: GraphData):
	clear_graph()
	for node in graph_data.nodes:
		var new_node: CraftingItemNode = CraftingItemNodeResource.instantiate()
		new_node.name = node.name
		new_node.position_offset = node.offset
		new_node.resource = node.element
		self.add_child(new_node)
	for con in graph_data.connections:
		self.connect_node(con.from_node, con.from_port, con.to_node, con.to_port)


func clear_graph():
	self.clear_connections()
	var nodes = self.get_children()
	for node in nodes:
		if node is GraphNode:
			node.queue_free()
