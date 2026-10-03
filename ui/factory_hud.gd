class_name FactoryHUD
extends CanvasLayer
signal resume_requested
signal restart_requested
var player: FactoryPlayer
var mixer: MixerMachine
var filler: CanFiller
var orders: OrderManager
var root_control: Control
var checklist: Label
var stage: Label
var held_label: Label
var prompt: Label
var controls: Label
var progress_bar: ProgressBar
var toast: Label
var timer_label: Label
var money_label: Label
var order_label: Label
var delivery_label: Label
var delivery_pips: Array[ColorRect] = []
var pause_overlay: ColorRect
var resume_button: Button
var batches: int = 0
var _toast_time: float = 0.0
var _prompt_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root_control = Control.new()
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	HudLayout.build(self)
	player.interaction.prompt_changed.connect(func(value: String): _prompt_text = value)
	player.interaction.feedback.connect(show_message)
	mixer.feedback.connect(show_message)
	filler.feedback.connect(show_message)
	mixer.batch_collected.connect(func(): batches += 1)
	orders.order_settled.connect(_on_settled)
	show_message("CLOCKED IN. Make six cans. Question your career later.")

func _process(delta: float) -> void:
	var seconds := ceili(orders.time_remaining)
	timer_label.text = "%02d:%02d" % [seconds / 60, seconds % 60] if orders.active else "NEXT..."
	timer_label.add_theme_color_override("font_color", Color("f08978") if seconds < 30 else HudStyle.CREAM)
	money_label.text = "$ %d" % orders.money
	order_label.text = "ORDER #%03d  /  GYM BRO GMBH" % orders.order_number
	delivery_label.text = "%d / 6 cans delivered" % orders.delivered
	for index in delivery_pips.size():
		delivery_pips[index].color = Color("278d83") if index < orders.delivered else Color("d6cdb7")
	_update_guide()
	var gamepad := player.input_source.gamepad_active
	var key := "X / Square" if gamepad else "E"
	prompt.text = ("[ %s ]  " % key + _prompt_text) if not _prompt_text.is_empty() else ""
	var item := player.grabber.held_item
	held_label.text = item.display_name() if is_instance_valid(item) else "Aim at a highlighted item or station"
	controls.text = "LS Move    RS Look    A/Cross Jump    X/Square Interact    B/Circle Drop · hold to throw\nRT/R2 Load    LT/L2 Inspect    RB/R1 Start machine    Start Pause" if gamepad else "WASD Move    MOUSE Look    SPACE Jump    E Interact    Q Drop · hold to throw\nLMB Load    RMB Inspect    F Start machine    ESC Pause"
	if not get_tree().paused:
		_toast_time = maxf(_toast_time - delta, 0.0)
	toast.visible = _toast_time > 0.0

func _update_guide() -> void:
	var item := player.grabber.held_item
	if is_instance_valid(item) and item.definition.kind == ItemDefinition.Kind.FILLED_CAN:
		stage.text = "04 / SHIP IT"
		checklist.text = "Take this can to the delivery desk.\nAim at the desk and interact.\nSix cans complete the order."
		progress_bar.value = orders.delivered / 6.0 * 100.0
	elif filler.servings_remaining > 0 or not filler.outputs.is_empty():
		stage.text = "03 / FILL IT"
		checklist.text = "Empty cans loaded: %d / 6\nLiquid remaining: %d servings\nLoad cans, then start the filler." % [filler.empty_cans, filler.servings_remaining]
		progress_bar.value = filler.progress() * 100.0
	elif is_instance_valid(item) and item.definition.kind == ItemDefinition.Kind.BATCH:
		stage.text = "02 / TRANSFER IT"
		checklist.text = "Carry the batch to the orange filler.\nAim at it and interact to load.\nThen collect six empty cans."
		progress_bar.value = 100
	else:
		stage.text = "01 / MIX IT" if mixer.state != MachineBase.State.FINISHED else "02 / TAKE THE BATCH"
		var lines: PackedStringArray = []
		for ingredient in mixer.recipe.ingredients:
			var loaded: bool = mixer.contents.get(ingredient.id, 0) > 0
			lines.append(("[OK]  " if loaded else "[  ]  ") + ingredient.display_name)
		checklist.text = "\n".join(lines)
		progress_bar.value = mixer.progress() * 100.0

func show_message(message: String) -> void:
	toast.text = message
	_toast_time = 4.0

func _on_settled(success: bool, amount: int) -> void:
	show_message("ORDER COMPLETE!  +$%d  /  Rating: Possibly Legal." % amount if success else "TRUCK LEFT WITHOUT YOU.  -$%d. New order incoming." % -amount)

func set_paused(value: bool) -> void:
	pause_overlay.visible = value
	if value:
		resume_button.grab_focus()
