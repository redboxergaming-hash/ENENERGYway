class_name DeliveryStation
extends MachineBase
var orders: OrderManager

func interact(grabber: PhysicsGrabber) -> bool:
	if orders.accept(grabber):
		if orders.active:
			feedback.emit("Delivered. One step closer to questionable greatness.")
		return true
	feedback.emit("Deliver a filled TROPICAL SHOCK can during an active order.")
	return false

func interaction_text(_holding: bool) -> String:
	if orders == null:
		return "Delivery desk"
	return "Deliver can  ·  %d / %d" % [orders.delivered, orders.specification.quantity]
