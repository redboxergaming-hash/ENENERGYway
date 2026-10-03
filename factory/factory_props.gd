class_name FactoryProps
extends RefCounted
const PALLET := preload("res://art/models/pallet.glb")
const CONE := preload("res://art/models/cone.glb")

static func model(parent: Node3D, scene: PackedScene, at: Vector3, angle: float = 0.0) -> Node3D:
	var node := scene.instantiate() as Node3D
	parent.add_child(node)
	node.position = at
	node.rotation.y = angle
	return node

static func shadow(parent: Node3D, at: Vector3, size: Vector2) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://art/shaders/contact_shadow.gdshader")
	visual.material_override = mat
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(visual)
	visual.position = at

static func sign_board(parent: Node3D, title: String, subtitle: String, at: Vector3, width: float, color: Color) -> Node3D:
	var sign := Node3D.new()
	parent.add_child(sign)
	sign.position = at
	Graybox.box(sign, Vector3(width, 0.8, 0.12), Vector3.ZERO, Color("253744"))
	Graybox.box(sign, Vector3(0.09, 0.8, 0.04), Vector3(-width / 2.0 + 0.07, 0, 0.08), color)
	Graybox.label(sign, title, Vector3(0, 0.11, 0.08), 34, color)
	Graybox.label(sign, subtitle, Vector3(0, -0.19, 0.081), 15, Color("eddfbf"))
	return sign

static func railing(parent: Node3D, at: Vector3, width: float) -> void:
	for x: float in [-width / 2.0, width / 2.0]:
		Graybox.cylinder(parent, 0.055, 0.95, at + Vector3(x, 0.48, 0), Color("efbb64"))
	for y: float in [0.38, 0.9]:
		Graybox.box(parent, Vector3(width, 0.07, 0.07), at + Vector3(0, y, 0), Color("efbb64"))
