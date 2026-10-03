class_name PlayerInput
extends Node
## Device-scoped actions keep commands separate from movement and game state.
@export var player_id: int = 1
@export var device_id: int = 0
@export var keyboard_mouse: bool = true
var gamepad_active: bool = false
var _mouse_delta := Vector2.ZERO
var _actions: Dictionary = {}

func _ready() -> void:
	for base: StringName in InputMap.get_actions():
		if String(base).begins_with("ui_") or String(base).begins_with("p"):
			continue
		var scoped := StringName("p%d_%s" % [player_id, base])
		_actions[base] = scoped
		if InputMap.has_action(scoped):
			InputMap.erase_action(scoped)
		InputMap.add_action(scoped, InputMap.action_get_deadzone(base))
		for original: InputEvent in InputMap.action_get_events(base):
			var event := original.duplicate() as InputEvent
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				event.device = device_id
			elif not keyboard_mouse:
				continue
			InputMap.action_add_event(scoped, event)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _exit_tree() -> void:
	for scoped: StringName in _actions.values():
		InputMap.erase_action(scoped)

func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventMouseMotion and keyboard_mouse:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_mouse_delta += event.relative
		if event.relative.length() > 1.0:
			gamepad_active = false
	elif event is InputEventJoypadButton and event.device == device_id:
		gamepad_active = true
	elif event is InputEventJoypadMotion and event.device == device_id:
		if absf(event.axis_value) > 0.25:
			gamepad_active = true
	elif event is InputEventKey and keyboard_mouse:
		gamepad_active = false

func movement() -> Vector2:
	return Input.get_vector(_actions[&"move_left"], _actions[&"move_right"],
		_actions[&"move_forward"], _actions[&"move_back"])

func look_delta(delta: float) -> Vector2:
	var stick := Input.get_vector(_actions[&"look_left"], _actions[&"look_right"],
		_actions[&"look_up"], _actions[&"look_down"])
	var result := _mouse_delta * 0.0022 + stick * delta * 2.3
	_mouse_delta = Vector2.ZERO
	return result

func pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(_actions[action])

func released(action: StringName) -> bool:
	return Input.is_action_just_released(_actions[action])

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if device == device_id and not connected:
		gamepad_active = false
		# Do not keep walking when a controller disappears mid-shift.
		for scoped: StringName in _actions.values():
			Input.action_release(scoped)
