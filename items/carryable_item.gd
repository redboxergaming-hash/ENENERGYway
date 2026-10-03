class_name CarryableItem
extends RigidBody3D

signal claimed(item: CarryableItem)
signal released(item: CarryableItem)
@export var ingredient: IngredientData
@export var batch_recipe: RecipeData
var holder: Node3D
var spawn_position := Vector3.ZERO
var is_consumed: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 4
	collision_mask = 7
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 4
	linear_damp = 0.8
	angular_damp = 2.5
	mass = ingredient.mass if ingredient else 2.0
	var physics := PhysicsMaterial.new()
	physics.bounce = 0.12
	physics.friction = 0.7
	physics_material_override = physics
	spawn_position = global_position
	var color := ingredient.color if ingredient else batch_recipe.color
	Graybox.box(self, Vector3(0.52, 0.65, 0.44), Vector3.ZERO, color)
	Graybox.box(self, Vector3(0.54, 0.14, 0.46), Vector3(0, -0.19, 0), Color("172f3d"))
	Graybox.cylinder(self, 0.1, 0.1, Vector3(0, 0.37, 0), Color("dce4df"))
	Graybox.label(self, "BATCH / 6" if batch_recipe else ingredient.display_name,
		Vector3(0, 0.04, 0.231), 15, Color("112634"))
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.54, 0.75, 0.46)
	var collider := CollisionShape3D.new()
	collider.shape = shape
	add_child(collider)

func _physics_process(_delta: float) -> void:
	if global_position.y < -8.0 and holder == null:
		global_position = spawn_position
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func display_name() -> String:
	return ingredient.display_name if ingredient else batch_recipe.display_name + " • 6 SERVINGS"

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
