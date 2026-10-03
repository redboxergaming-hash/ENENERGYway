extends Node3D
## Readable, asset-free graybox; collision is built from the same dimensions as art.
const INK := Color("18343f")
const TEAL := Color("467e83")
const CREAM := Color("b8c7bd")
const YELLOW := Color("f8c254")

func _ready() -> void:
	_build_shell()
	_build_storage()
	_build_details()
	_lighting()

func _build_shell() -> void:
	Graybox.solid_box(self, Vector3(18, 0.4, 17), Vector3(0, -0.2, 0), Color("657c7d"))
	Graybox.solid_box(self, Vector3(18, 5.5, 0.4), Vector3(0, 2.75, -8.5), CREAM)
	Graybox.solid_box(self, Vector3(0.4, 5.5, 17), Vector3(-9, 2.75, 0), CREAM)
	Graybox.solid_box(self, Vector3(0.4, 5.5, 17), Vector3(9, 2.75, 0), CREAM)
	Graybox.solid_box(self, Vector3(18, 5.5, 0.4), Vector3(0, 2.75, 8.5), CREAM)
	for x: float in [-8.7, 8.7]:
		Graybox.box(self, Vector3(0.04, 1.2, 16.8), Vector3(x, 0.62, 0), TEAL)
		for z: float in [-6.0, 0.0, 6.0]:
			Graybox.box(self, Vector3(0.22, 5.1, 0.28), Vector3(x, 2.6, z), INK)
	Graybox.box(self, Vector3(17.6, 1.2, 0.05), Vector3(0, 0.62, -8.26), TEAL)
	for x in range(-8, 9, 2):
		Graybox.box(self, Vector3(0.025, 0.008, 16.7), Vector3(x, 0.007, 0), Color("72898a"))
	for z in range(-8, 9, 2):
		Graybox.box(self, Vector3(17.7, 0.008, 0.025), Vector3(0, 0.007, z), Color("72898a"))
	# Keep travel lanes clear, with enough room to learn before adding co-op bottlenecks.
	for x: float in [-2.0, 4.1]:
		Graybox.box(self, Vector3(0.08, 0.012, 9.0), Vector3(x, 0.016, 0.0), YELLOW)
	Graybox.box(self, Vector3(6.1, 0.012, 0.08), Vector3(1.05, 0.016, 4.5), YELLOW)
	Graybox.box(self, Vector3(7.5, 1.5, 0.1), Vector3(0, 3.9, -8.22), INK)
	Graybox.label(self, "ENERGY INC.", Vector3(0, 4.13, -8.14), 100, YELLOW)
	Graybox.label(self, "SLEEP IS TEMPORARY. PRODUCTIVITY IS FOREVER.", Vector3(0, 3.54, -8.13), 24)

func _build_storage() -> void:
	Graybox.solid_box(self, Vector3(3.4, 0.16, 1.3), Vector3(-5.4, 0.95, -2.8), INK)
	for x: float in [-6.8, -4.0]:
		Graybox.solid_box(self, Vector3(0.13, 0.9, 1.1), Vector3(x, 0.45, -2.8), TEAL)
	Graybox.label(self, "01  /  INGREDIENTS", Vector3(-5.4, 2.5, -3.4), 38, YELLOW)
	Graybox.label(self, "ONE OF EACH. TRUST THE PROCESS.", Vector3(-5.4, 2.14, -3.4), 19)
	var names := ["WATER", "CAFFEINE", "MANGO"]
	var colors := [Color("38bae8"), Color("c4ef44"), Color("ff7d26")]
	for i in 3:
		var x := -6.5 + i * 1.1
		Graybox.box(self, Vector3(0.85, 0.015, 0.95), Vector3(x, 1.045, -2.8), colors[i])
		Graybox.label(self, names[i], Vector3(x, 0.8, -2.12), 17)

func _build_details() -> void:
	Graybox.label(self, "02  /  MIXING", Vector3(1.2, 3.15, -4.1), 42, YELLOW)
	Graybox.label(self, "THREE INGREDIENTS. QUESTIONABLE AMBITION.", Vector3(1.2, 2.79, -4.1), 18)
	Graybox.box(self, Vector3(3, 1.65, 0.12), Vector3(-5.4, 3.5, -8.2), Color("f8c254"))
	Graybox.label(self, "SAFETY
THIRD", Vector3(-5.4, 3.63, -8.1), 64, INK)
	Graybox.label(self, "THE FIRST TWO WERE EXPENSIVE.", Vector3(-5.4, 2.89, -8.09), 14, INK)
	Graybox.box(self, Vector3(2.9, 2.2, 0.14), Vector3(5.8, 2.2, -8.2), INK)
	Graybox.label(self, "TRAINING SHIFT", Vector3(5.8, 2.92, -8.1), 32, YELLOW)
	Graybox.label(self, "TROPICAL SHOCK
WATER + CAFFEINE + MANGO

MIX TIME  00:05
OUTPUT  6 SERVINGS", Vector3(5.8, 2.12, -8.09), 22)
	Graybox.solid_box(self, Vector3(2.2, 1.1, 1.8), Vector3(6.6, 0.55, -2.8), Color("778b89"))
	Graybox.label(self, "03 / FILLING
NEXT MILESTONE", Vector3(6.6, 1.8, -2.8), 26, Color("e2e4d1"))
	for i in 6:
		Graybox.box(self, Vector3(0.25, 0.015, 1.8), Vector3(5.65 + i * 0.38, 1.112, -2.8), YELLOW)
	# These are scenery; physical throwable props are spawned by the session.
	Graybox.solid_box(self, Vector3(2.5, 0.65, 0.7), Vector3(-7, 0.325, 4.7), TEAL)
	Graybox.label(self, "BREAK AREA
AUTHORIZED DAYDREAMING ONLY", Vector3(-7, 2.0, 4.4), 23)

func _lighting() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("899faa")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("d5e3ec")
	settings.ambient_light_energy = 0.35
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -28, 0)
	sun.light_color = Color("fff0ce")
	sun.light_energy = 0.8
	sun.shadow_enabled = true
	add_child(sun)
	for x: float in [-5.0, 4.0]:
		Graybox.box(self, Vector3(3, 0.12, 0.5), Vector3(x, 5.2, -1), Color("f5e9bd"))
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, 4.4, -1)
		lamp.light_energy = 0.25
		lamp.omni_range = 10.0
		lamp.light_color = Color("f9e5bc")
		add_child(lamp)
