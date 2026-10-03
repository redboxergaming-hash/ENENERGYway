class_name OrderManager
extends Node
## Runtime ledger. Delivery is an atomic transaction and a settled order cannot pay twice.
signal order_changed
signal delivery_accepted(delivered: int)
signal order_settled(success: bool, amount: int)
signal balance_changed(balance: int)
@export var specification: OrderData
var delivered: int = 0
var time_remaining: float = 0.0
var money: int = 0
var orders_completed: int = 0
var order_number: int = 0
var active: bool = false
var intermission: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	begin_order()

func begin_order() -> void:
	order_number += 1
	delivered = 0
	time_remaining = specification.deadline
	active = true
	intermission = 0.0
	order_changed.emit()

func _physics_process(delta: float) -> void:
	if active:
		time_remaining = maxf(time_remaining - delta, 0.0)
		if time_remaining <= 0.0:
			_settle(false)
	else:
		intermission -= delta
		if intermission <= 0.0:
			begin_order()

func accept(grabber: PhysicsGrabber) -> bool:
	var item := grabber.held_item
	if not active or time_remaining <= 0.0 or item == null or item.is_consumed:
		return false
	if item.definition.kind != ItemDefinition.Kind.FILLED_CAN or item.batch_recipe == null:
		return false
	if item.batch_recipe.id != specification.recipe.id or item.holder != grabber.worker:
		return false
	grabber.consume_held()
	delivered += 1
	delivery_accepted.emit(delivered)
	if delivered >= specification.quantity:
		_settle(true)
	return true

func _settle(success: bool) -> void:
	if not active:
		return
	active = false
	intermission = 3.0
	var amount := specification.reward if success else -specification.penalty
	money += amount
	if success:
		orders_completed += 1
	balance_changed.emit(money)
	order_settled.emit(success, amount)
