extends Node3D
const MODEL := preload("res://art/models/worker.glb")
var phase: float = 0.0
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var head: Node3D
var torso: Node3D

func _ready() -> void:
	var model := MODEL.instantiate() as Node3D
	add_child(model)
	left_leg = model.find_child("LeftLeg", true, false)
	right_leg = model.find_child("RightLeg", true, false)
	left_arm = model.find_child("LeftArm", true, false)
	right_arm = model.find_child("RightArm", true, false)
	head = model.find_child("Head", true, false)
	torso = model.find_child("Torso", true, false)

func _process(delta: float) -> void:
	var worker := get_parent() as FactoryPlayer
	var speed := Vector2(worker.velocity.x, worker.velocity.z).length()
	phase += delta * (speed * 2.5 + 0.8)
	var amplitude := minf(speed / 5.0, 1.0)
	left_leg.rotation.x = sin(phase) * 0.55 * amplitude
	right_leg.rotation.x = -sin(phase) * 0.55 * amplitude
	var carrying := is_instance_valid(worker.grabber.held_item)
	var arm_angle := 1.1 if carrying else -sin(phase) * 0.36 * amplitude
	left_arm.rotation.x = lerpf(left_arm.rotation.x, arm_angle, delta * 12.0)
	right_arm.rotation.x = lerpf(right_arm.rotation.x, 1.1 if carrying else -arm_angle, delta * 12.0)
	torso.rotation.z = sin(phase) * 0.045 * amplitude
	head.rotation.z = sin(phase * 0.5) * 0.025
	position.y = absf(sin(phase)) * 0.04 * amplitude
