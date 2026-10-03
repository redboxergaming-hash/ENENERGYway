class_name HudStyle
extends RefCounted
const CREAM := Color("f5e9cf")
const MUTED := Color("adc6c2")
const YELLOW := Color("f6c76b")
const INK := Color("253744")
const BOLD := preload("res://art/fonts/OpenSans-Bold.ttf")
const REGULAR := preload("res://art/fonts/OpenSans-Semibold.ttf")

static func panel(parent: Control, at: Vector2, size: Vector2, light: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = CREAM if light else Color(0.08, 0.15, 0.18, 0.96)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0.02, 0.06, 0.07, 0.2)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	panel.position = at
	panel.custom_minimum_size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel

static func label(parent: Node, text: String, size: int = 20, color: Color = CREAM, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", BOLD if bold else REGULAR)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

static func anchor(control: Control, point: Vector2, rect: Rect2) -> void:
	control.anchor_left = point.x
	control.anchor_right = point.x
	control.anchor_top = point.y
	control.anchor_bottom = point.y
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.end.x
	control.offset_bottom = rect.end.y

static func button(parent: Control, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.add_theme_font_override("font", BOLD)
	button.add_theme_font_size_override("font_size", 18)
	parent.add_child(button)
	return button
