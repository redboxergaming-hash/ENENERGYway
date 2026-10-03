class_name Graybox
extends RefCounted
## Shared primitive construction. Visual helpers never change gameplay state.
static func material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.76
	result.metallic = metallic
	return result

static func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material(color)
	parent.add_child(visual)
	visual.position = at
	return visual

static func cylinder(parent: Node3D, radius: float, height: float, at: Vector3,
		color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = material(color, 0.15)
	parent.add_child(visual)
	visual.position = at
	return visual

static func solid_box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	parent.add_child(body)
	body.position = at
	box(body, size, Vector3.ZERO, color)
	var shape := BoxShape3D.new()
	shape.size = size
	var collider := CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	return body

static func label(parent: Node3D, value: String, at: Vector3, size: int = 36,
		color: Color = Color.WHITE) -> Label3D:
	var result := Label3D.new()
	result.text = value
	result.font_size = size * 3
	result.pixel_size = 0.007 / 3.0
	result.modulate = color
	result.outline_size = 8
	parent.add_child(result)
	result.position = at
	return result
