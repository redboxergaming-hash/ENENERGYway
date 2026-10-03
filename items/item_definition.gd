class_name ItemDefinition
extends Resource
## Immutable item archetype; quantity, ownership and product identity live on instances.
enum Kind { INGREDIENT, BATCH, EMPTY_CAN, FILLED_CAN }
@export var id: StringName
@export var display_name: String
@export var kind: Kind = Kind.INGREDIENT
@export var visual: PackedScene
@export var mass: float = 1.0
@export var collider_size := Vector3(0.54, 0.8, 0.5)
@export var cylindrical: bool = false
