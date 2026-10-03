class_name FocusHighlight
extends RefCounted
static var _material: ShaderMaterial

static func apply(node: Node, enabled: bool) -> void:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = preload("res://art/shaders/focus_outline.gdshader")
	if node is MeshInstance3D:
		node.material_overlay = _material if enabled else null
	for child in node.get_children():
		apply(child, enabled)
