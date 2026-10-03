extends Node3D
## Presentation observes signals; wobble never moves the authoritative collider.
var rotor: MeshInstance3D
var status: Label3D
var liquid: MeshInstance3D
var machine: MixerMachine
var phase: float = 0.0

func _ready() -> void:
	machine = get_parent() as MixerMachine
	Graybox.box(self, Vector3(2.05, 0.65, 1.45), Vector3(0, 0.35, 0), Color("183847"))
	Graybox.cylinder(self, 0.92, 1.45, Vector3(0, 1.4, 0), Color("4f9997"))
	Graybox.cylinder(self, 0.99, 0.13, Vector3(0, 2.12, 0), Color("c5d6ca"))
	liquid = Graybox.cylinder(self, 0.84, 0.06, Vector3(0, 2.17, 0), Color("ffd064"))
	rotor = Graybox.box(self, Vector3(1.5, 0.12, 0.12), Vector3(0, 2.25, 0), Color("172d3c"))
	Graybox.box(self, Vector3(1.7, 0.64, 0.13), Vector3(0, 1.28, 0.78), Color("112a35"))
	Graybox.label(self, "MIX-O-MATIC  /  01", Vector3(0, 1.43, 0.86), 24)
	status = Graybox.label(self, "AWAITING INGREDIENTS", Vector3(0, 1.17, 0.87), 18, Color("bdeb80"))
	Graybox.label(self, "DO NOT LICK THE SCIENCE", Vector3(0, 0.48, 0.74), 16, Color("ffc565"))
	Graybox.label(self, "BATCH OUT", Vector3(1.85, 0.62, 0.9), 18)
	machine.state_changed.connect(_on_state_changed)
	machine.progress_changed.connect(_on_progress)
	machine.contents_changed.connect(_on_contents)

func _process(delta: float) -> void:
	if machine.state == MachineBase.State.PROCESSING:
		phase += delta * 18.0
		rotor.rotation.y += delta * 10.0
		rotation.z = sin(phase) * 0.008
	else:
		rotation.z = 0.0

func _on_state_changed(_previous: MachineBase.State, current: MachineBase.State) -> void:
	if current == MachineBase.State.FINISHED:
		status.text = "POSSIBLY LEGAL.  →"
	elif current == MachineBase.State.IDLE:
		status.text = "AWAITING INGREDIENTS"

func _on_progress(fraction: float) -> void:
	status.text = "AGGRESSIVE SCIENCE  %d%%" % int(fraction * 100)

func _on_contents() -> void:
	status.text = "%d / 3 INGREDIENTS" % machine.contents.size()
