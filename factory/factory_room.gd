extends Node3D
## Original modular workshop dressing. Gameplay colliders stay separate from decorative meshes.
const INK := Color("253744")
const TEAL := Color("338f8a")
const CREAM := Color("aebdb4")
const YELLOW := Color("f2bd61")

func _ready() -> void:
	_shell()
	_storage()
	_workshop()
	var lights := Node3D.new()
	lights.set_script(preload("res://factory/factory_lighting.gd"))
	add_child(lights)

func _shell() -> void:
	Graybox.solid_box(self, Vector3(18, 0.4, 14.5), Vector3(0, -0.2, 1.25), Color("50696c"))
	# Large, subtle tiles; no distracting high-contrast grid.
	for x in 9:
		for z in 7:
			var c := Color("637d7b") if (x + z) % 2 == 0 else Color("607978")
			Graybox.box(self, Vector3(1.992, 0.018, 1.992), Vector3(-8 + x * 2, 0.008, -5 + z * 2), c)
	for x: float in [-9, 9]:
		Graybox.solid_box(self, Vector3(0.4, 5.2, 14.5), Vector3(x, 2.6, 1.25), CREAM)
		Graybox.box(self, Vector3(0.03, 1.32, 14.4), Vector3(x - signf(x) * 0.215, 0.7, 1.25), TEAL)
		Graybox.box(self, Vector3(0.04, 0.11, 14.4), Vector3(x - signf(x) * 0.24, 1.42, 1.25), YELLOW)
	Graybox.solid_box(self, Vector3(18, 5.2, 0.35), Vector3(0, 2.6, -6), CREAM)
	Graybox.solid_box(self, Vector3(18, 5.2, 0.35), Vector3(0, 2.6, 8.5), CREAM)
	Graybox.box(self, Vector3(17.8, 1.32, 0.04), Vector3(0, 0.7, -5.8), TEAL)
	Graybox.box(self, Vector3(17.8, 0.1, 0.04), Vector3(0, 1.42, -5.77), YELLOW)
	for x: float in [-8.6, -3.3, 3.5, 8.6]:
		Graybox.box(self, Vector3(0.2, 5.1, 0.25), Vector3(x, 2.55, -5.71), INK)
	for x: float in [-5.8, 5.9]:
		_window(Vector3(x, 3.6, -5.74))
	Graybox.box(self, Vector3(5.1, 1.15, 0.15), Vector3(0.15, 3.69, -5.72), INK)
	Graybox.label(self, "ENERGY INC.", Vector3(0.15, 3.82, -5.62), 70, YELLOW)
	Graybox.label(self, "SLEEP IS TEMPORARY. PRODUCTIVITY IS FOREVER.", Vector3(0.15, 3.39, -5.61), 17, Color("eae1c9"))
	var ceiling := Graybox.box(self, Vector3(18, 0.12, 14.5), Vector3(0, 5.3, 1.25), Color("6c8a88"))
	ceiling.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Overhead trusses and pendant lights ground the factory in a real room.
	for z: float in [-4.8, 3.9]:
		Graybox.box(self, Vector3(17.8, 0.24, 0.27), Vector3(0, 4.88, z), INK)
		for x: float in [-5, 1, 6]:
			Graybox.cylinder(self, 0.025, 0.46, Vector3(x, 4.55, z), INK)
			Graybox.cylinder(self, 0.34, 0.18, Vector3(x, 4.26, z), YELLOW)
			Graybox.cylinder(self, 0.29, 0.03, Vector3(x, 4.15, z), Color("f9e7ad"))
	# Two main travel lanes with dashed edges, plus colored station pads.
	for z in 8:
		Graybox.box(self, Vector3(0.07, 0.025, 0.48), Vector3(-2.9, 0.025, -3.3 + z), YELLOW)
	for x in 12:
		Graybox.box(self, Vector3(0.48, 0.025, 0.07), Vector3(-6 + x, 0.025, -1.5), YELLOW)
	for at: Vector3 in [Vector3(1.2, 0.025, -3.2), Vector3(6.1, 0.025, -3.2), Vector3(6.2, 0.025, 3.7)]:
		Graybox.box(self, Vector3(3.7, 0.025, 3.2), at, Color("466566"))
		FactoryProps.shadow(self, at + Vector3(0, 0.03, 0), Vector2(3.8, 3.3))

func _window(at: Vector3) -> void:
	Graybox.box(self, Vector3(4.0, 1.9, 0.06), at, INK)
	Graybox.box(self, Vector3(3.74, 1.66, 0.03), at + Vector3(0, 0, 0.05), Color("86bdc6"))
	for x: float in [-1.25, 0, 1.25]:
		Graybox.box(self, Vector3(0.07, 1.72, 0.06), at + Vector3(x, 0, 0.09), CREAM)
	Graybox.box(self, Vector3(3.85, 0.07, 0.06), at + Vector3(0, 0.05, 0.1), CREAM)

func _storage() -> void:
	Graybox.solid_box(self, Vector3(3.55, 0.17, 1.35), Vector3(-5.4, 0.99, -2.8), Color("deb76f"))
	for x: float in [-7.0, -3.8]:
		Graybox.solid_box(self, Vector3(0.15, 1.0, 1.18), Vector3(x, 0.5, -2.8), INK)
		Graybox.box(self, Vector3(0.1, 2.6, 0.1), Vector3(x, 1.4, -3.36), TEAL)
	Graybox.box(self, Vector3(3.55, 0.12, 1.0), Vector3(-5.4, 2.24, -2.94), TEAL)
	FactoryProps.sign_board(self, "01  INGREDIENTS", "ONE OF EACH. TRUST THE PROCESS.", Vector3(-5.4, 2.86, -3.36), 3.8, YELLOW)
	for i in 3:
		var x := -6.5 + i * 1.1
		var c: Color = [Color("64b9d8"), Color("bfe264"), Color("ee8847")][i]
		Graybox.box(self, Vector3(0.88, 0.02, 0.95), Vector3(x, 1.087, -2.8), c)
		Graybox.label(self, ["WATER", "CAFFEINE", "MANGO"][i], Vector3(x, 0.88, -2.11), 18, Color("f4e4c5"))
		Graybox.box(self, Vector3(0.6, 0.32, 0.45), Vector3(x, 2.46, -2.97), c)
		Graybox.box(self, Vector3(0.13, 0.325, 0.46), Vector3(x, 2.46, -2.97), CREAM)
	FactoryProps.shadow(self, Vector3(-5.4, 0.035, -2.8), Vector2(4, 2.0))

func _workshop() -> void:
	FactoryProps.sign_board(self, "02  MIX IT", "FIVE SECONDS OF QUESTIONABLE SCIENCE", Vector3(1.2, 2.96, -4.6), 3.4, Color("74d3bf"))
	FactoryProps.sign_board(self, "03  FILL IT", "INSERT CANS. ACQUIRE AMBITION.", Vector3(6.1, 2.96, -4.6), 3.4, Color("f4bd62"))
	FactoryProps.sign_board(self, "EMPTY CANS", "COMPLIMENTARY AIR INCLUDED", Vector3(6.8, 2.18, 0.15), 2.6, Color("bde1dc"))
	var delivery_sign := FactoryProps.sign_board(self, "04  SHIP IT", "GYM BRO GMBH  /  DISPATCH", Vector3(8.65, 2.7, 3.6), 3.5, YELLOW)
	delivery_sign.rotation.y = -PI / 2.0
	for y in 10:
		Graybox.box(self, Vector3(0.07, 0.2, 3.5), Vector3(8.69, 0.18 + y * 0.22, 3.6), Color("527977"))
	FactoryProps.railing(self, Vector3(6.2, 0, 5.0), 3.5)
	FactoryProps.model(self, FactoryProps.PALLET, Vector3(7.2, 0, 6.9), 0.1)
	FactoryProps.model(self, FactoryProps.PALLET, Vector3(-7.5, 0, -4.95), -0.2)
	FactoryProps.model(self, FactoryProps.CONE, Vector3(4.4, 0, 5.05))
	FactoryProps.model(self, FactoryProps.CONE, Vector3(7.8, 0, 5.05))
	Graybox.solid_box(self, Vector3(2.6, 0.5, 0.72), Vector3(-7, 0.25, 4.4), TEAL)
	FactoryProps.sign_board(self, "SAFETY THIRD", "THE FIRST TWO WERE EXPENSIVE.", Vector3(-7.0, 1.9, 4.25), 2.8, YELLOW)
	# Plumbing on the back wall adds silhouette detail without blocking player movement.
	for y: float in [1.85, 2.07]:
		Graybox.box(self, Vector3(7.0, 0.085, 0.085), Vector3(2.7, y, -5.67), Color("c39e66"))
