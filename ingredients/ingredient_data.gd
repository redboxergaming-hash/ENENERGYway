class_name IngredientData
extends Resource
## Immutable ingredient configuration; quantities belong to machines, not resources.
@export var id: StringName
@export var display_name: String
@export var color: Color = Color.WHITE
@export_multiline var warning: String
@export_range(0.1, 10.0) var mass: float = 1.0
@export_range(0.0, 3.0) var instability: float = 0.0
@export_range(0.0, 3.0) var stickiness: float = 0.0

@export var visual: PackedScene
