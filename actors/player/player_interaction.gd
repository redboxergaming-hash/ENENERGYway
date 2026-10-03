class_name PlayerInteraction
extends Node

signal prompt_changed(text: String)
signal feedback(message: String)
var camera: Camera3D
var worker: CharacterBody3D
var grabber: PhysicsGrabber
var target: CollisionObject3D
var _focused: CollisionObject3D
const REACH: float = 3.4

func _physics_process(_delta: float) -> void:
	var origin := camera.global_position
	var end := origin - camera.global_basis.z * 9.5
	var query := PhysicsRayQueryParameters3D.create(origin, end, 13)
	query.exclude = [worker.get_rid()]
	if is_instance_valid(grabber.held_item):
		query.exclude += [grabber.held_item.get_rid()]
	var hit := worker.get_world_3d().direct_space_state.intersect_ray(query)
	target = null
	if not hit.is_empty():
		if (hit.position as Vector3).distance_to(worker.global_position + Vector3.UP) <= REACH:
			target = hit.collider as CollisionObject3D
	if not target is CarryableItem and not target is MachineBase:
		target = _assist_target()
	var prompt := ""
	if target is CarryableItem and grabber.held_item == null:
		prompt = "Pick up " + target.display_name()
	elif target is MachineBase:
		prompt = target.interaction_text(grabber.held_item != null)
	var next_focus: CollisionObject3D = target if target is CarryableItem or target is MachineBase else null
	if next_focus != _focused:
		if is_instance_valid(_focused):
			FocusHighlight.apply(_focused, false)
		_focused = next_focus
		if is_instance_valid(_focused):
			FocusHighlight.apply(_focused, true)
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
		feedback.emit("Aim at a station to use. Q / B / Circle to drop or throw.")

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
		feedback.emit("Batch: load into the filler. Can: fill it, then deliver it.")

func _assist_target() -> CollisionObject3D:
	# Small screen-space allowance makes tiny cans comfortable on a stick.
	# Every candidate still requires range and an unobstructed physics ray.
	var nearest: CollisionObject3D
	var best_distance: float = 28.0
	var center := camera.get_viewport().get_visible_rect().size / 2.0
	for candidate: CollisionObject3D in get_tree().get_nodes_in_group("interactable"):
		if candidate == grabber.held_item or candidate.is_queued_for_deletion():
			continue
		var at := candidate.global_position
		if candidate is MachineBase:
			at += Vector3.UP * 1.1
		if camera.is_position_behind(at) or at.distance_to(worker.global_position + Vector3.UP) > REACH:
			continue
		var distance := camera.unproject_position(at).distance_to(center)
		if distance >= best_distance:
			continue
		var query := PhysicsRayQueryParameters3D.create(camera.global_position, at, 13)
		query.exclude = [worker.get_rid()]
		if is_instance_valid(grabber.held_item):
			query.exclude += [grabber.held_item.get_rid()]
		var hit := worker.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and hit.collider == candidate:
			nearest = candidate
			best_distance = distance
	return nearest
