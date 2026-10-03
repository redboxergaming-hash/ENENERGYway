class_name HudStyle
extends RefCounted
const CREAM := Color("f0f1df")
const MUTED := Color("a9c3c5")
const YELLOW := Color("ffcc63")

static func panel(parent: Control, at: Vector2, size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.09, 0.12, 0.94)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	panel.position = at
	panel.custom_minimum_size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel

static func label(parent: Node, text: String, size: int = 20, color: Color = CREAM) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label
