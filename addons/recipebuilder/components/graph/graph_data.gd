extends Resource

class_name GraphData

## Used by the builder plugin only
@export var connections: Array[Dictionary]
@export var nodes: Array[NodeData]

## Used by the game to setup all of the recipes
@export var crafting_catalog: CraftingCatalog
