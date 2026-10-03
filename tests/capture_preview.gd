extends SceneTree
## Optional rendered smoke test; requires an actual or virtual display.
func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var scene := load("res://factory/factory.tscn").instantiate() as Node3D
	root.add_child(scene)
	current_scene = scene
	await create_timer(1.5).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://docs/milestone-02.png")
	print("PREVIEW_CAPTURE: ", error_string(error))
	quit(error)
