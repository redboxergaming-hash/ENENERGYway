class_name HudLayout
extends RefCounted

static func build(hud: FactoryHUD) -> void:
	var root := hud.root_control
	var brand := HudStyle.panel(root, Vector2(24, 22), Vector2(292, 65))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	brand.add_child(row)
	var icon := TextureRect.new()
	icon.texture = preload("res://art/icons/app.svg")
	icon.custom_minimum_size = Vector2(42, 42)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	row.add_child(icon)
	HudStyle.label(row, "ENERGY INC.", 27, HudStyle.CREAM, true)
	var timer_panel := HudStyle.panel(root, Vector2.ZERO, Vector2(190, 65))
	HudStyle.anchor(timer_panel, Vector2(0.5, 0), Rect2(-95, 22, 190, 65))
	hud.timer_label = HudStyle.label(timer_panel, "03:00", 30, HudStyle.CREAM, true)
	hud.timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var money_panel := HudStyle.panel(root, Vector2.ZERO, Vector2(230, 65))
	HudStyle.anchor(money_panel, Vector2(1, 0), Rect2(-254, 22, 230, 65))
	hud.money_label = HudStyle.label(money_panel, "$ 0", 28, HudStyle.YELLOW, true)
	hud.money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var ticket := HudStyle.panel(root, Vector2.ZERO, Vector2(300, 215), true)
	HudStyle.anchor(ticket, Vector2(1, 0), Rect2(-324, 110, 300, 215))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	ticket.add_child(column)
	hud.order_label = HudStyle.label(column, "ORDER #001  /  GYM BRO GMBH", 13, HudStyle.INK, true)
	HudStyle.label(column, "TROPICAL\nSHOCK", 26, HudStyle.INK, true)
	hud.delivery_label = HudStyle.label(column, "0 / 6 cans delivered", 18, HudStyle.INK)
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 6)
	column.add_child(slots)
	for index in 6:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(35, 6)
		slots.add_child(pip)
		hud.delivery_pips.append(pip)
	HudStyle.label(column, "+ $420   /   late: - $100", 14, Color("647f76"))
	var guide := HudStyle.panel(root, Vector2.ZERO, Vector2(294, 175))
	HudStyle.anchor(guide, Vector2(0, 1), Rect2(24, -278, 294, 175))
	var guide_column := VBoxContainer.new()
	guide_column.add_theme_constant_override("separation", 6)
	guide.add_child(guide_column)
	hud.stage = HudStyle.label(guide_column, "01 / MIX IT", 18, HudStyle.YELLOW, true)
	hud.checklist = HudStyle.label(guide_column, "", 15)
	hud.progress_bar = ProgressBar.new()
	hud.progress_bar.custom_minimum_size = Vector2(254, 8)
	hud.progress_bar.show_percentage = false
	guide_column.add_child(hud.progress_bar)
	var crosshair := HudStyle.label(root, "·", 34, HudStyle.CREAM, true)
	HudStyle.anchor(crosshair, Vector2(0.5, 0.5), Rect2(-6, -24, 20, 40))
	hud.prompt = HudStyle.label(root, "", 20, HudStyle.YELLOW, true)
	HudStyle.anchor(hud.prompt, Vector2(0.5, 1), Rect2(-425, -175, 850, 34))
	hud.prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.held_label = HudStyle.label(root, "", 16)
	HudStyle.anchor(hud.held_label, Vector2(0.5, 1), Rect2(-350, -130, 700, 28))
	hud.held_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var footer := HudStyle.panel(root, Vector2.ZERO, Vector2(960, 58))
	HudStyle.anchor(footer, Vector2(0.5, 1), Rect2(-480, -80, 960, 58))
	hud.controls = HudStyle.label(footer, "", 14, HudStyle.MUTED)
	hud.controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.toast = HudStyle.label(root, "", 18, HudStyle.YELLOW, true)
	HudStyle.anchor(hud.toast, Vector2(0.5, 0), Rect2(-360, 110, 720, 65))
	hud.toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_build_pause(hud)

static func _build_pause(hud: FactoryHUD) -> void:
	hud.pause_overlay = ColorRect.new()
	hud.pause_overlay.color = Color(0.05, 0.1, 0.13, 0.95)
	hud.root_control.add_child(hud.pause_overlay)
	hud.pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	hud.pause_overlay.add_child(column)
	HudStyle.anchor(column, Vector2(0.5, 0.5), Rect2(-245, -205, 490, 410))
	column.add_theme_constant_override("separation", 16)
	HudStyle.label(column, "PRODUCTIVITY PAUSED.", 29, HudStyle.YELLOW, true)
	HudStyle.label(column, "Management has been mildly inconvenienced.", 16)
	hud.resume_button = HudStyle.button(column, "Resume shift")
	hud.resume_button.pressed.connect(func(): hud.resume_requested.emit())
	HudStyle.button(column, "Restart shift").pressed.connect(func(): hud.restart_requested.emit())
	HudStyle.button(column, "Toggle fullscreen").pressed.connect(func():
		var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN))
	HudStyle.button(column, "Quit game").pressed.connect(func(): hud.get_tree().quit())
	hud.pause_overlay.hide()
