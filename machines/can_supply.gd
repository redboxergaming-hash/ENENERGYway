class_name CanSupply
extends MachineBase
const ITEM_SCENE := preload("res://items/carryable_item.tscn")

func interact(grabber: PhysicsGrabber) -> bool:
	if grabber.held_item != null:
		feedback.emit("Free your hands first. You only have the standard two.")
		return false
	var item := ITEM_SCENE.instantiate() as CarryableItem
	item.definition = ItemCatalog.EMPTY_CAN
	get_parent().add_child(item)
	item.global_position = grabber.anchor.global_position
	item.spawn_position = global_position + Vector3(0, 1.65, 0.7)
	return grabber.grab(item)

func interaction_text(_holding: bool) -> String:
	return "Take an empty can"
