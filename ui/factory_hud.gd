class_name FactoryHUD
extends CanvasLayer

signal resume_requested
signal restart_requested
var player: FactoryPlayer
var mixer: MixerMachine
var root_control: Control
var checklist: Label
var stage: Label
var held_label: Label
var prompt: Label
var controls: Label
var progress_bar: ProgressBar
var toast: Label
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
	var title := HudStyle.label(root_control, "ENERGY INC.", 36, HudStyle.YELLOW)
	title.position = Vector2(32, 22)
	var subtitle := HudStyle.label(root_control, "FACTORY 01   /   RESEARCH & QUESTIONABLE DEVELOPMENT", 14, HudStyle.MUTED)
	subtitle.position = Vector2(34, 68)
	var panel := HudStyle.panel(root_control, Vector2(32, 112), Vector2(320, 0))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	HudStyle.label(column, "TRAINING SHIFT  /  01", 14, HudStyle.YELLOW)
	HudStyle.label(column, "TROPICAL
SHOCK", 30)
	HudStyle.label(column, "1 batch → 6 servings", 18, HudStyle.MUTED)
	checklist = HudStyle.label(column, "", 18)
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(270, 7)
	progress_bar.show_percentage = false
	column.add_child(progress_bar)
	stage = HudStyle.label(column, "", 16, HudStyle.YELLOW)
	var build := HudStyle.label(root_control, "MILESTONE 01
SINGLE-PLAYER LAB", 14, HudStyle.MUTED)
	build.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	build.offset_left = -250
	build.offset_top = 28
	build.offset_right = -32
	build.offset_bottom = 80
	build.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var crosshair := HudStyle.label(root_control, "+", 26)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.offset_left = -8
	crosshair.offset_top = -18
	crosshair.offset_right = 8
	crosshair.offset_bottom = 18
	prompt = HudStyle.label(root_control, "", 22, HudStyle.YELLOW)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.offset_left = -480
	prompt.offset_right = 480
	prompt.offset_top = -154
	prompt.offset_bottom = -114
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	held_label = HudStyle.label(root_control, "", 17)
	held_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	held_label.offset_left = -480
	held_label.offset_right = 480
	held_label.offset_top = -113
	held_label.offset_bottom = -80
	held_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls = HudStyle.label(root_control, "", 16, HudStyle.MUTED)
	controls.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	controls.offset_left = -660
	controls.offset_right = 660
	controls.offset_top = -64
	controls.offset_bottom = -12
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast = HudStyle.label(root_control, "", 18, HudStyle.YELLOW)
	toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast.offset_left = -400
	toast.offset_right = 400
	toast.offset_top = 84
	toast.offset_bottom = 110
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_build_pause()
	player.interaction.prompt_changed.connect(func(value: String): _prompt_text = value)
	player.interaction.feedback.connect(show_message)
	mixer.feedback.connect(show_message)
	mixer.batch_collected.connect(func(): batches += 1)

func _process(delta: float) -> void:
	var lines: PackedStringArray = []
	for ingredient in mixer.recipe.ingredients:
		var loaded: bool = mixer.contents.get(ingredient.id, 0) > 0
		lines.append(("[OK]  " if loaded else "[  ]  ") + ingredient.display_name)
	checklist.text = "
".join(lines)
	progress_bar.value = mixer.progress() * 100.0
	match mixer.state:
		MachineBase.State.PROCESSING: stage.text = "MIXING  /  %.1fs" % (mixer.processing_time - mixer.elapsed)
		MachineBase.State.FINISHED: stage.text = "READY → TAKE THE BATCH"
		_: stage.text = "COLLECT → LOAD → MIX" if batches == 0 else "BATCHES MADE: %d  /  TRY AGAIN" % batches
	var gamepad := player.input_source.gamepad_active
	var key := "X / Square" if gamepad else "E"
	prompt.text = ("[ %s ]  " % key + _prompt_text) if not _prompt_text.is_empty() else ""
	var item := player.grabber.held_item
	held_label.text = "CARRYING  /  " + item.display_name() if is_instance_valid(item) else "Aim at a container or the mixer to interact"
	controls.text = "LS  Move     RS  Look     A / Cross  Jump     X / Square  Interact     B / Circle  Drop / hold to throw
RT / R2  Load     LT / L2  Inspect     RB / R1  Start mixer     Start  Pause" if gamepad else "WASD  Move     MOUSE  Look     SPACE  Jump     E  Interact     Q  Drop / hold to throw
LMB  Load     RMB  Inspect     F  Start mixer     ESC  Pause"
	if not get_tree().paused:
		_toast_time = maxf(_toast_time - delta, 0.0)
	toast.visible = _toast_time > 0.0

func show_message(message: String) -> void:
	toast.text = message
	_toast_time = 4.0

func _build_pause() -> void:
	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.02, 0.05, 0.08, 0.92)
	root_control.add_child(pause_overlay)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	pause_overlay.add_child(column)
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.offset_left = -230
	column.offset_right = 230
	column.offset_top = -130
	column.offset_bottom = 130
	column.add_theme_constant_override("separation", 18)
	HudStyle.label(column, "PRODUCTIVITY PAUSED.", 30, HudStyle.YELLOW)
	HudStyle.label(column, "Management has been mildly inconvenienced.", 17)
	resume_button = Button.new()
	resume_button.text = "Resume shift"
	resume_button.custom_minimum_size.y = 52
	column.add_child(resume_button)
	resume_button.pressed.connect(func(): resume_requested.emit())
	var restart := Button.new()
	restart.text = "Restart training"
	restart.custom_minimum_size.y = 52
	column.add_child(restart)
	restart.pressed.connect(func(): restart_requested.emit())
	pause_overlay.hide()

func set_paused(value: bool) -> void:
	pause_overlay.visible = value
	if value:
		resume_button.grab_focus()
