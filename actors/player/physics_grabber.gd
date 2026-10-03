class_name PhysicsGrabber
extends Node
## Held objects remain real rigid bodies. Velocity servo is bounded and wall-aware.
signal held_changed(item: CarryableItem)
@export var follow_speed: float = 14.0
@export var max_speed: float = 12.0
var held_item: CarryableItem
var worker: CharacterBody3D
var anchor: Node3D
var chest: Node3D

func grab(item: CarryableItem) -> bool:
	if held_item != null or not item.try_claim(worker):
		return false
	held_item = item
	held_changed.emit(item)
	return true

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(held_item):
		held_item = null
		return
	if held_item.is_consumed:
		held_item = null
		held_changed.emit(null)
		return
	var target := anchor.global_position
	var query := PhysicsRayQueryParameters3D.create(chest.global_position, target, 1)
	query.exclude = [worker.get_rid(), held_item.get_rid()]
	var hit := worker.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		target = hit.position + hit.normal * 0.4
	var offset := target - held_item.global_position
	if offset.length() > 3.5:
		drop()
		return
	held_item.linear_velocity = (offset * follow_speed + worker.velocity * 0.35).limit_length(max_speed)
	held_item.angular_velocity *= 0.7

func drop(throw_strength: float = 0.0) -> void:
	if not is_instance_valid(held_item):
		return
	var item := held_item
	held_item = null
	var direction := -anchor.global_basis.z
	item.release(direction * throw_strength + Vector3.UP * throw_strength * 0.12)
	held_changed.emit(null)

func consume_held() -> void:
	if not is_instance_valid(held_item):
		return
	var item := held_item
	held_item = null
	item.consume()
	held_changed.emit(null)
