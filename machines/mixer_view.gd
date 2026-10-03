extends Node3D
const MODEL := preload("res://art/models/mixer.glb")
var rotor: Node3D
var status: Label3D
var machine: MixerMachine
var phase: float = 0.0

func _ready() -> void:
	machine = get_parent() as MixerMachine
	var model := MODEL.instantiate() as Node3D
	add_child(model)
	rotor = model.find_child("Rotor", true, false)
	status = Graybox.label(self, "READY TO MIX", Vector3(0, 1.4, 0.93), 16, Color("9bddbd"))
	Graybox.label(self, "MIX-O-MATIC", Vector3(0, 1.67, 0.7), 22, Color("f5e5bd"))
	Graybox.label(self, "DO NOT LICK THE SCIENCE", Vector3(0, 0.53, 0.82), 11, Color("253744"))
	machine.state_changed.connect(_on_state_changed)
	machine.progress_changed.connect(_on_progress)
	machine.contents_changed.connect(_on_contents)

func _process(delta: float) -> void:
	if machine.state == MachineBase.State.PROCESSING:
		phase += delta * 18.0
		rotor.rotation.y += delta * 10.0
		rotation.z = sin(phase) * 0.006
	else:
		rotation.z = 0.0

func _on_state_changed(_previous: MachineBase.State, current: MachineBase.State) -> void:
	if current == MachineBase.State.FINISHED:
		status.text = "BATCH READY  >"
	elif current == MachineBase.State.IDLE:
		status.text = "READY TO MIX"

func _on_progress(fraction: float) -> void:
	status.text = "SCIENCE  %d%%" % int(fraction * 100)

func _on_contents() -> void:
	status.text = "%d / 3 INGREDIENTS" % machine.contents.size()
