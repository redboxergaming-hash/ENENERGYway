class_name MixerMachine
extends MachineBase

signal batch_created(item: CarryableItem)
signal batch_collected
const ITEM_SCENE := preload("res://items/carryable_item.tscn")
@export var recipe: RecipeData
var contents: Dictionary = {}
var output_item: CarryableItem
@onready var output: Marker3D = $Output

func _ready() -> void:
	assert(recipe != null and recipe.is_valid(), "Mixer needs a valid recipe resource.")
	processing_time = recipe.mix_seconds

func interact(grabber: PhysicsGrabber) -> bool:
	return try_load(grabber) if grabber.held_item != null else try_start()

func can_accept(item: CarryableItem) -> bool:
	if item == null or item.ingredient == null or item.is_consumed:
		return false
	if state not in [State.IDLE, State.LOADING]:
		return false
	var id := item.ingredient.id
	return contents.get(id, 0) < recipe.required_units(id)

func try_load(grabber: PhysicsGrabber) -> bool:
	var item := grabber.held_item
	if not can_accept(item):
		feedback.emit("Already loaded, wrong ingredient, or mixer busy.")
		return false
	var id := item.ingredient.id
	contents[id] = int(contents.get(id, 0)) + 1
	grabber.consume_held()
	_set_state(State.LOADING)
	contents_changed.emit()
	return true

func try_start() -> bool:
	if state not in [State.IDLE, State.LOADING] or not recipe.matches(contents):
		feedback.emit("Needs WATER + CAFFEINE + MANGO. Science insists.")
		return false
	_begin_processing()
	feedback.emit("Mixing. Please remain reasonably employed.")
	return true

func _finish_processing() -> void:
	# Exactly one output per cycle; keep the output slot occupied until claimed.
	if output_item != null:
		return
	output_item = ITEM_SCENE.instantiate() as CarryableItem
	output_item.batch_recipe = recipe
	get_parent().add_child(output_item)
	output_item.global_position = output.global_position
	output_item.spawn_position = output.global_position
	output_item.claimed.connect(_on_batch_claimed, CONNECT_ONE_SHOT)
	_set_state(State.FINISHED)
	batch_created.emit(output_item)
	feedback.emit("TROPICAL SHOCK ready. Rating: Possibly Legal.")

func _on_batch_claimed(_item: CarryableItem) -> void:
	output_item = null
	contents.clear()
	elapsed = 0.0
	_set_state(State.IDLE)
	contents_changed.emit()
	batch_collected.emit()

func interaction_text(holding: bool) -> String:
	match state:
		State.PROCESSING:
			return "MIXING  /  %d%%" % int(progress() * 100)
		State.FINISHED:
			return "Batch ready on the orange output tray →"
		State.BROKEN, State.OVERHEATED:
			return "Maintenance required"
	if holding:
		return "Load ingredient"
	if recipe.matches(contents):
		return "Start mixer • 5 seconds"
	return "Load water, caffeine and mango"
