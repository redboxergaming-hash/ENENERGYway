extends Node3D
var phase: float = 0.0
var left_foot: MeshInstance3D
var right_foot: MeshInstance3D

func _ready() -> void:
	Graybox.box(self, Vector3(0.63, 0.66, 0.36), Vector3(0, 0.95, 0), Color("e8a442"))
	Graybox.box(self, Vector3(0.45, 0.17, 0.38), Vector3(0, 0.63, 0), Color("193a4c"))
	Graybox.box(self, Vector3(0.43, 0.4, 0.4), Vector3(0, 1.5, 0), Color("d6a880"))
	Graybox.box(self, Vector3(0.52, 0.14, 0.55), Vector3(0, 1.74, 0), Color("f7dc72"))
	Graybox.cylinder(self, 0.28, 0.15, Vector3(0, 1.83, 0.02), Color("f7dc72"))
	Graybox.box(self, Vector3(0.37, 0.12, 0.03), Vector3(0, 1.53, -0.21), Color("233d49"))
	for side: float in [-1.0, 1.0]:
		Graybox.box(self, Vector3(0.18, 0.45, 0.2), Vector3(side * 0.42, 0.99, -0.06), Color("e8a442"))
		Graybox.box(self, Vector3(0.19, 0.2, 0.23), Vector3(side * 0.42, 0.72, -0.1), Color("213b4b"))
	left_foot = Graybox.box(self, Vector3(0.22, 0.5, 0.29), Vector3(-0.17, 0.28, -0.04), Color("253f50"))
	right_foot = Graybox.box(self, Vector3(0.22, 0.5, 0.29), Vector3(0.17, 0.28, -0.04), Color("253f50"))

func _process(delta: float) -> void:
	var worker := get_parent() as CharacterBody3D
	var speed := Vector2(worker.velocity.x, worker.velocity.z).length()
	phase += delta * speed * 2.4
	var amplitude := minf(speed / 5.0, 1.0)
	left_foot.rotation.x = sin(phase) * 0.4 * amplitude
	right_foot.rotation.x = -sin(phase) * 0.4 * amplitude
