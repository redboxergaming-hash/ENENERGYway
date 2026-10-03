extends Node
## Base mappings use Godot's standardized physical gamepad layout (Xbox / PS).
const BUTTONS: Dictionary = {
	"jump": JOY_BUTTON_A, "interact": JOY_BUTTON_X,
	"drop": JOY_BUTTON_B, "context": JOY_BUTTON_RIGHT_SHOULDER,
	"pause": JOY_BUTTON_START,
}
const KEYS: Dictionary = {
	"move_left": KEY_A, "move_right": KEY_D,
	"move_forward": KEY_W, "move_back": KEY_S,
	"jump": KEY_SPACE, "interact": KEY_E, "drop": KEY_Q,
	"context": KEY_F, "pause": KEY_ESCAPE,
}

func _enter_tree() -> void:
	for action: String in KEYS:
		_add_action(action)
		var key := InputEventKey.new()
		key.physical_keycode = KEYS[action]
		InputMap.action_add_event(action, key)
	for action: String in BUTTONS:
		_add_action(action)
		var button := InputEventJoypadButton.new()
		button.button_index = BUTTONS[action]
		InputMap.action_add_event(action, button)
	for action: String in ["use", "secondary"]:
		_add_action(action)
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT if action == "use" else MOUSE_BUTTON_RIGHT
		InputMap.action_add_event(action, mouse)
		var trigger := InputEventJoypadMotion.new()
		trigger.axis = JOY_AXIS_TRIGGER_RIGHT if action == "use" else JOY_AXIS_TRIGGER_LEFT
		trigger.axis_value = 1.0
		InputMap.action_add_event(action, trigger)
	var axes := {
		"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
		"move_forward": [JOY_AXIS_LEFT_Y, -1.0], "move_back": [JOY_AXIS_LEFT_Y, 1.0],
		"look_left": [JOY_AXIS_RIGHT_X, -1.0], "look_right": [JOY_AXIS_RIGHT_X, 1.0],
		"look_up": [JOY_AXIS_RIGHT_Y, -1.0], "look_down": [JOY_AXIS_RIGHT_Y, 1.0],
	}
	for action: String in axes:
		_add_action(action)
		var motion := InputEventJoypadMotion.new()
		motion.axis = axes[action][0]
		motion.axis_value = axes[action][1]
		InputMap.action_add_event(action, motion)

func _add_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)
