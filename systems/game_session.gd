extends Node3D
## Composition root owns the room, player, recipe supply, and presentation wiring.
const ITEM_SCENE := preload("res://items/carryable_item.tscn")
const HUD_SCRIPT := preload("res://ui/factory_hud.gd")
@onready var player: FactoryPlayer = $Player
@onready var mixer: MixerMachine = $Mixer
var hud: FactoryHUD
var supplies: Array[CarryableItem] = []

func _ready() -> void:
	# Only this composition root and UI run when paused; simulation is pausable.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	_spawn_supplies()
	hud = HUD_SCRIPT.new() as FactoryHUD
	hud.player = player
	hud.mixer = mixer
	add_child(hud)
	hud.resume_requested.connect(func(): set_paused(false))
	hud.restart_requested.connect(restart)
	mixer.batch_collected.connect(_spawn_supplies)

func _spawn_supplies() -> void:
	# Replenish only consumed bottles; no duplicates if the signal is repeated.
	for index in mixer.recipe.ingredients.size():
		if index < supplies.size() and is_instance_valid(supplies[index]) and not supplies[index].is_consumed:
			continue
		var item := ITEM_SCENE.instantiate() as CarryableItem
		item.ingredient = mixer.recipe.ingredients[index]
		item.position = Vector3(-6.5 + index * 1.1, 1.55, -2.8)
		item.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(item)
		if index < supplies.size():
			supplies[index] = item
		else:
			supplies.append(item)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	player.cancel_charge()
	get_tree().paused = value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED
	hud.set_paused(value)

func restart() -> void:
	set_paused(false)
	get_tree().reload_current_scene()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud):
		set_paused(true)
