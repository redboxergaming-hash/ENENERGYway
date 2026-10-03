class_name CarryableItem
extends RigidBody3D

signal claimed(item: CarryableItem)
signal released(item: CarryableItem)
@export var definition: ItemDefinition = preload("res://items/ingredient.tres")
@export var ingredient: IngredientData
@export var batch_recipe: RecipeData
var servings: int = 0
var holder: Node3D
var spawn_position := Vector3.ZERO
var is_consumed: bool = false

func _ready() -> void:
	add_to_group("interactable")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 4
	collision_mask = 7
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 4
	linear_damp = 0.8
	angular_damp = 2.5
	mass = ingredient.mass if ingredient else definition.mass
	var physics := PhysicsMaterial.new()
	physics.bounce = 0.1
	physics.friction = 0.7
	physics_material_override = physics
	spawn_position = global_position
	var shape: Shape3D
	if definition.cylindrical:
		var cylinder := CylinderShape3D.new()
		cylinder.radius = definition.collider_size.x / 2.0
		cylinder.height = definition.collider_size.y
		shape = cylinder
	else:
		var box := BoxShape3D.new()
		box.size = definition.collider_size
		shape = box
	var collider := CollisionShape3D.new()
	collider.shape = shape
	add_child(collider)
	var view := Node3D.new()
	view.set_script(preload("res://items/item_view.gd"))
	add_child(view)

func _physics_process(_delta: float) -> void:
	if global_position.y < -8.0 and holder == null:
		global_position = spawn_position
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func display_name() -> String:
	if ingredient:
		return ingredient.display_name
	if definition.kind == ItemDefinition.Kind.BATCH:
		return "%s · %d servings" % [batch_recipe.display_name, servings]
	if definition.kind == ItemDefinition.Kind.FILLED_CAN:
		return batch_recipe.display_name + " CAN"
	return definition.display_name

func try_claim(worker: Node3D) -> bool:
	if holder != null or is_consumed or is_queued_for_deletion():
		return false
	holder = worker
	sleeping = false
	gravity_scale = 0.0
	add_collision_exception_with(worker)
	claimed.emit(self)
	return true

func release(impulse: Vector3 = Vector3.ZERO) -> void:
	if holder == null:
		return
	remove_collision_exception_with(holder)
	holder = null
	gravity_scale = 1.0
	apply_central_impulse(impulse * mass)
	released.emit(self)

func consume() -> void:
	is_consumed = true
	release()
	collision_layer = 0
	collision_mask = 0
	queue_free()
