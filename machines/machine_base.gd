class_name MachineBase
extends StaticBody3D
## Authoritative simulation seam: no input polling, HUD references or visual effects.
signal state_changed(previous: State, current: State)
signal progress_changed(fraction: float)
signal contents_changed
signal feedback(message: String)

enum State { IDLE, LOADING, PROCESSING, FINISHED, BROKEN, OVERHEATED }
@export var processing_time: float = 5.0
@export var input_slots: int = 3
@export var output_slots: int = 1
@export var power_usage: float = 2.0
@export var temperature: float = 20.0
@export var damage: float = 0.0
@export_range(0.0, 1.0) var jam_probability: float = 0.0
var state: State = State.IDLE
var elapsed: float = 0.0

func _physics_process(delta: float) -> void:
	if state != State.PROCESSING:
		return
	elapsed = minf(elapsed + delta, processing_time)
	progress_changed.emit(progress())
	if elapsed >= processing_time:
		_finish_processing()

func progress() -> float:
	return clampf(elapsed / maxf(processing_time, 0.01), 0.0, 1.0)

func _set_state(next: State) -> void:
	if state == next:
		return
	var previous := state
	state = next
	state_changed.emit(previous, next)

func _begin_processing() -> void:
	elapsed = 0.0
	_set_state(State.PROCESSING)
	progress_changed.emit(0.0)

func _finish_processing() -> void:
	_set_state(State.FINISHED)

## Override these commands in machine implementations; interaction never knows subclasses.
func interact(_grabber: PhysicsGrabber) -> bool:
	return false

func try_start() -> bool:
	return false

func interaction_text(_holding: bool) -> String:
	return "Machine unavailable"
