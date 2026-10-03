class_name PlayerInteraction
extends Node

signal prompt_changed(text: String)
signal feedback(message: String)
var camera: Camera3D
var worker: CharacterBody3D
var grabber: PhysicsGrabber
var target: CollisionObject3D
const REACH: float = 3.4

func _physics_process(_delta: float) -> void:
	var origin := camera.global_position
	var end := origin - camera.global_basis.z * 8.0
	var query := PhysicsRayQueryParameters3D.create(origin, end, 13)
	query.exclude = [worker.get_rid()]
	if is_instance_valid(grabber.held_item):
		query.exclude += [grabber.held_item.get_rid()]
	var hit := worker.get_world_3d().direct_space_state.intersect_ray(query)
	target = null
	if not hit.is_empty():
		if (hit.position as Vector3).distance_to(worker.global_position + Vector3.UP) <= REACH:
			target = hit.collider as CollisionObject3D
	var prompt := ""
	if target is CarryableItem and grabber.held_item == null:
		prompt = "Pick up " + target.display_name()
	elif target is MachineBase:
		prompt = target.interaction_text(grabber.held_item != null)
	prompt_changed.emit(prompt)

func interact() -> void:
	if target is MachineBase:
		target.interact(grabber)
	elif target is CarryableItem and grabber.held_item == null:
		grabber.grab(target)

func use_held() -> void:
	if target is MachineBase and grabber.held_item != null:
		target.interact(grabber)
	elif grabber.held_item != null:
		feedback.emit("Aim at the mixer to load. Q / B / Circle to drop or throw.")

func contextual() -> void:
	if target is MachineBase:
		target.try_start()

func inspect_held() -> void:
	if not is_instance_valid(grabber.held_item):
		return
	var item := grabber.held_item
	if item.ingredient:
		feedback.emit(item.ingredient.warning)
	else:
		feedback.emit("6 servings of Tropical Shock. Filling station arrives next milestone.")
