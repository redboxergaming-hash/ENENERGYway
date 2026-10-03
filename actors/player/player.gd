class_name FactoryPlayer
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 22.0
@export var jump_speed: float = 7.0
@onready var input_source: PlayerInput = $PlayerInput
@onready var grabber: PhysicsGrabber = $PhysicsGrabber
@onready var interaction: PlayerInteraction = $PlayerInteraction
@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var body_visual: Node3D = $WorkerVisual
var _drop_charge: float = -1.0
var _coyote: float = 0.0
var _jump_buffer: float = 0.0
var _spawn := Vector3.ZERO

func _ready() -> void:
	_spawn = global_position
	grabber.worker = self
	grabber.anchor = $CameraPivot/HandAnchor
	grabber.chest = $Chest
	interaction.worker = self
	interaction.camera = camera
	interaction.grabber = grabber
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var look := input_source.look_delta(delta)
	pivot.rotation.y -= look.x
	pivot.rotation.x = clampf(pivot.rotation.x - look.y, -0.95, 0.55)
	var movement := input_source.movement()
	var direction := Basis(Vector3.UP, pivot.rotation.y) * Vector3(movement.x, 0, movement.y)
	velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	_coyote = 0.12 if is_on_floor() else maxf(_coyote - delta, 0.0)
	_jump_buffer = 0.12 if input_source.pressed(&"jump") else maxf(_jump_buffer - delta, 0.0)
	if _coyote > 0.0 and _jump_buffer > 0.0:
		velocity.y = jump_speed
		_coyote = 0.0
		_jump_buffer = 0.0
	elif not is_on_floor():
		velocity.y -= 18.0 * delta
	move_and_slide()
	_push_objects()
	body_visual.rotation.y = lerp_angle(body_visual.rotation.y, pivot.rotation.y, delta * 12.0)
	if input_source.pressed(&"interact"):
		interaction.interact()
	if input_source.pressed(&"use"):
		interaction.use_held()
	if input_source.pressed(&"secondary"):
		interaction.inspect_held()
	if input_source.pressed(&"context"):
		interaction.contextual()
	if input_source.pressed(&"drop") and grabber.held_item != null:
		_drop_charge = 0.0
	if _drop_charge >= 0.0:
		_drop_charge += delta
		if input_source.released(&"drop"):
			grabber.drop(0.0 if _drop_charge < 0.22 else minf(_drop_charge, 1.0) * 9.0)
			_drop_charge = -1.0
	if global_position.y < -8.0:
		grabber.drop()
		global_position = _spawn
		velocity = Vector3.ZERO

func cancel_charge() -> void:
	_drop_charge = -1.0

func _push_objects() -> void:
	for index in get_slide_collision_count():
		var hit := get_slide_collision(index)
		var item := hit.get_collider() as CarryableItem
		if item != null and item.holder == null:
			var direction := -hit.get_normal()
			direction.y = 0.0
			item.apply_central_impulse(direction * 0.5)
