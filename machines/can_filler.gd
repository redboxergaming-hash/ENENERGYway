class_name CanFiller
extends MachineBase
## One physical batch, one empty can and one serving per output. No shared resource mutation.
signal can_created(item: CarryableItem)
signal batch_loaded
const ITEM_SCENE := preload("res://items/carryable_item.tscn")
var recipe: RecipeData
var servings_remaining: int = 0
var empty_cans: int = 0
var outputs: Array[CarryableItem] = []
@onready var output: Marker3D = $Output

func _ready() -> void:
	super._ready()
	processing_time = 1.0
	input_slots = 6
	output_slots = 6

func interact(grabber: PhysicsGrabber) -> bool:
	return try_load(grabber) if grabber.held_item != null else try_start()

func try_load(grabber: PhysicsGrabber) -> bool:
	var item := grabber.held_item
	if item == null or item.is_consumed or state in [State.BROKEN, State.OVERHEATED]:
		return false
	if item.definition.kind == ItemDefinition.Kind.BATCH:
		if servings_remaining > 0 or state == State.PROCESSING or item.servings != input_slots or item.batch_recipe == null:
			feedback.emit("Tank full. Finish this six-serving batch first.")
			return false
		recipe = item.batch_recipe
		servings_remaining = item.servings
		grabber.consume_held()
		batch_loaded.emit()
	elif item.definition.kind == ItemDefinition.Kind.EMPTY_CAN:
		if empty_cans >= input_slots:
			feedback.emit("Six cans is a queue. Seven is a problem.")
			return false
		empty_cans += 1
		grabber.consume_held()
	else:
		feedback.emit("Needs a mixed batch or an EMPTY CAN.")
		return false
	if state != State.PROCESSING:
		_set_state(State.LOADING)
	contents_changed.emit()
	return true

func try_start() -> bool:
	if state == State.PROCESSING or state in [State.BROKEN, State.OVERHEATED]:
		return false
	if servings_remaining <= 0 or empty_cans <= 0 or outputs.size() >= output_slots:
		feedback.emit("Load liquid + empty cans. Clear the output tray if full.")
		return false
	_begin_processing()
	return true

func _finish_processing() -> void:
	var item := ITEM_SCENE.instantiate() as CarryableItem
	item.definition = ItemCatalog.FILLED_CAN
	item.batch_recipe = recipe
	item.servings = 1
	# Find an unoccupied tray position; claiming an output frees its slot.
	var slot := 0
	var occupied: Array[int] = []
	for existing in outputs:
		occupied.append(existing.get_meta("tray_slot", -1))
	while slot in occupied:
		slot += 1
	item.set_meta("tray_slot", slot)
	get_parent().add_child(item)
	item.global_position = output.global_position + Vector3((slot % 2 - 0.5) * 0.28, 0, (slot / 2) * 0.43 - 0.43)
	item.spawn_position = item.global_position
	item.claimed.connect(_on_can_claimed, CONNECT_ONE_SHOT)
	outputs.append(item)
	empty_cans -= 1
	servings_remaining -= 1
	_set_state(State.FINISHED)
	contents_changed.emit()
	can_created.emit(item)
	if empty_cans > 0 and servings_remaining > 0 and outputs.size() < output_slots:
		_begin_processing()

func _on_can_claimed(item: CarryableItem) -> void:
	outputs.erase(item)
	if state == State.FINISHED:
		_set_state(State.LOADING if servings_remaining > 0 or empty_cans > 0 else State.IDLE)
	contents_changed.emit()

func interaction_text(holding: bool) -> String:
	if holding:
		return "Load batch / empty can  ·  %d / 6 cans" % empty_cans
	if state == State.PROCESSING:
		return "FILLING  ·  %d servings left" % servings_remaining
	if empty_cans > 0 and servings_remaining > 0:
		return "Start filling  ·  %d cans queued" % empty_cans
	return "Load batch + empty cans  ·  %d / 6 cans" % empty_cans
