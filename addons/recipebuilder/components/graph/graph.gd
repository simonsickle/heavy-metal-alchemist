@tool
extends GraphEdit

class_name RecipeGraph

signal graph_modified

var CraftingItemNodeResource := preload("res://addons/recipebuilder/components/graph/node/crafting_item_node.tscn")

func _ready() -> void:
	self.connection_request.connect(_on_connection_request)
	self.disconnection_request.connect(_on_disconnect_request)
	self.delete_nodes_request.connect(_on_delete_node_request)
	self.end_node_move.connect(_on_node_move_end)

func add_new_node() -> void:
	var new_node: CraftingItemNode = CraftingItemNodeResource.instantiate()
	
	# If there are children, we always want to add the next near the last created node
	var number_of_children = self.get_child_count()
	if number_of_children > 1:
		var last_child_pos := (self.get_children()[number_of_children - 1] as CraftingItemNode).position
		new_node.position_offset = Vector2(last_child_pos.x + 16, last_child_pos.y + 16)
	
	new_node.node_changed.connect(_on_node_changed)
	
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
	
	graph_data.crafting_catalog = _build_crafting_catalog()
	
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
			node_data.item_label = node.get_label()
			node_data.item_icon = node.get_icon_texture()
			graph_data.nodes.append(node_data)
	return graph_data


func _build_crafting_catalog() -> CraftingCatalog:
	var catalog: CraftingCatalog = CraftingCatalog.new()
	
	## First we need to create every crafting item and add it to the catalog
	for node in self.get_children():
		if node is CraftingItemNode:
			var crafting_item = CraftingItemResource.new()
			crafting_item.label = node.get_label()
			crafting_item.icon = node.get_icon_texture()
			
			catalog.add_item(crafting_item)
	
	## Next we need to get recipes and add them to the path
	for con in self.get_connection_list():
		## An ingredent
		var start: CraftingItemNode = get_node(NodePath(con.from_node))
		## the item this recipe belongs to
		var end: CraftingItemNode = get_node(NodePath(con.to_node))
		
		catalog.add_ingredient(end.get_label(), start.get_label())
	
	return catalog

func init_graph(graph_data: GraphData):
	clear_graph()
	for node in graph_data.nodes:
		var new_node: CraftingItemNode = CraftingItemNodeResource.instantiate()
		new_node.name = node.name
		new_node.position_offset = node.offset
		new_node.restore_label = node.item_label
		new_node.restore_icon_texture = node.item_icon
		
		new_node.node_changed.connect(_on_node_changed)
		self.add_child(new_node)
	for con in graph_data.connections:
		self.connect_node(con.from_node, con.from_port, con.to_node, con.to_port)


func clear_graph():
	self.clear_connections()
	var nodes = self.get_children()
	for node in nodes:
		if node is GraphNode:
			node.queue_free()
