extends SceneTree
## Real scene/physics regression suite. No third-party test addon required.
var failures: int = 0
var checks: int = 0
var scene: Node3D
var player: FactoryPlayer
var mixer: MixerMachine

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func frames(count: int) -> void:
	for index in count:
		await physics_frame
	await process_frame

func press(action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(2)

func aim(at: Vector3) -> void:
	player.camera.look_at(at, Vector3.UP)
	await frames(2)

func _run() -> void:
	scene = load("res://factory/factory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	mixer = scene.get_node("Mixer")
	await frames(40)
	check(scene.hud.root_control.size.x > 1000, "HUD root fills viewport")
	check(scene.hud.controls.get_global_rect().position.y > 0, "Bottom control hints remain on screen")
	scene.set_paused(true)
	check(scene.hud.pause_overlay.visible and scene.hud.resume_button.has_focus(), "Pause menu is visible and controller-focused")
	scene.set_paused(false)
	check(mixer.recipe.is_valid(), "Recipe resource is valid")
	check(mixer.recipe.servings == 6 and mixer.recipe.mix_seconds == 5.0, "Tropical Shock yields six servings after five seconds")
	check(scene.supplies.size() == 3, "Exactly three initial ingredient objects")
	await aim(scene.supplies[0].global_position)
	check(player.interaction.target == null, "Distant ingredients cannot be picked up")
	player.camera.rotation = Vector3.ZERO
	check(not mixer.try_start(), "Incomplete mixer cannot start")
	check(mixer.state == MachineBase.State.IDLE, "Rejected start leaves mixer idle")
	check(InputMap.has_action("p1_interact"), "Player-scoped input bindings registered")
	var start: Vector3 = player.global_position
	Input.action_press("p1_move_forward")
	await frames(30)
	Input.action_release("p1_move_forward")
	await frames(12)
	check(player.global_position.z < start.z - 1.0, "Movement command moves character")
	await press(&"p1_jump")
	check(player.global_position.y > 0.2, "Jump command leaves the ground")
	await frames(65)
	check(player.is_on_floor(), "Character lands on factory collision")

	for index in 3:
		var item: CarryableItem = scene.supplies[index]
		player.global_position = Vector3(item.global_position.x, 0.05, -0.8)
		player.velocity = Vector3.ZERO
		await frames(3)
		await aim(item.global_position)
		check(player.interaction.target == item, "Camera ray reaches ingredient %d" % index)
		await press(&"p1_interact")
		check(player.grabber.held_item == item, "Interact picks up ingredient %d" % index)
		check(not item.freeze and item.holder == player, "Held ingredient remains dynamic and owned")
		check(not item.try_claim(player), "Already owned item cannot be claimed twice")
		await frames(20)
		check(item.global_position.distance_to(player.grabber.anchor.global_position) < 0.7, "Physics carry follows hand")
		# Move the actor and the held item together, then use the actual ray/action path.
		var shift: Vector3 = Vector3(1.2, 0.05, -0.9) - player.global_position
		player.global_position += shift
		item.global_position += shift
		await aim(mixer.global_position + Vector3(0, 1.3, 0.75))
		check(player.interaction.target == mixer, "Camera ray reaches mixer")
		await press(&"p1_use")
		check(player.grabber.held_item == null, "Loading consumes the held ingredient")
		check(mixer.contents.size() == index + 1, "Mixer accounts for ingredient exactly once")
		if index == 0:
			var duplicate := load("res://items/carryable_item.tscn").instantiate() as CarryableItem
			duplicate.ingredient = mixer.recipe.ingredients[0]
			scene.add_child(duplicate)
			check(not mixer.can_accept(duplicate), "Duplicate ingredient is rejected")
			duplicate.queue_free()
	check(mixer.recipe.matches(mixer.contents), "All loaded quantities match the recipe")
	await press(&"p1_context")
	check(mixer.state == MachineBase.State.PROCESSING, "Context action starts mixer")
	check(not mixer.try_start(), "Repeated start does not create a second process")
	var before: float = mixer.elapsed
	scene.set_paused(true)
	await frames(10)
	check(is_equal_approx(mixer.elapsed, before), "Pause freezes machine simulation")
	scene.set_paused(false)
	await frames(270)
	check(mixer.state == MachineBase.State.PROCESSING, "Mixer does not finish before five seconds")
	await frames(45)
	check(mixer.state == MachineBase.State.FINISHED, "Mixer finishes after five seconds")
	var batch := mixer.output_item
	check(is_instance_valid(batch) and batch.batch_recipe == mixer.recipe, "Physical batch carries recipe identity")
	check(not mixer.try_start(), "Occupied output slot prevents another cycle")
	player.global_position = Vector3(3.05, 0.05, -0.6)
	player.velocity = Vector3.ZERO
	await frames(3)
	await aim(batch.global_position)
	check(player.interaction.target == batch, "Output tray can be targeted")
	await press(&"p1_interact")
	check(player.grabber.held_item == batch, "Finished batch can be picked up")
	check(mixer.state == MachineBase.State.IDLE and mixer.contents.is_empty(), "Collecting output resets mixer")
	check(scene.supplies.all(func(item): return is_instance_valid(item)), "Consumed ingredients are replenished")
	await frames(25)
	Input.action_press("p1_drop")
	await frames(40)
	Input.action_release("p1_drop")
	await frames(2)
	check(player.grabber.held_item == null and batch.holder == null, "Charged throw releases ownership")
	check(batch.linear_velocity.length() > 2.0, "Charged throw adds physical impulse")
	check(batch.gravity_scale == 1.0, "Dropped item regains gravity")
	batch.global_position = Vector3(0, -12, 0)
	await frames(2)
	check(batch.global_position.y > 0.0, "Out-of-bounds batch returns to output area")
	await _second_cycle()
	# Device routing is checked without claiming that physical hardware was exercised.
	var second := PlayerInput.new()
	second.player_id = 2
	second.device_id = 1
	second.keyboard_mouse = false
	scene.add_child(second)
	var events := InputMap.action_get_events("p2_interact")
	check(events.size() == 1 and events[0].device == 1, "Second player's actions are controller-scoped")
	check(not InputMap.action_get_events("p2_move_forward").any(func(e): return e is InputEventKey), "Second player does not inherit keyboard")
	scene.restart()
	await frames(5)
	scene = current_scene
	check(is_instance_valid(scene) and scene.get_node("Mixer").state == MachineBase.State.IDLE, "Restart loads a clean idle factory")
	check(scene.supplies.size() == 3 and scene.hud.batches == 0, "Restart resets supplies and training count")
	check(InputMap.has_action("p1_interact") and not InputMap.has_action("p2_interact"), "Restart recreates only the active player's input")
	scene.queue_free()
	await frames(3)
	check(not InputMap.has_action("p1_interact"), "Scene teardown removes scoped bindings")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _second_cycle() -> void:
	for item: CarryableItem in scene.supplies:
		check(player.grabber.grab(item), "Fresh supply can be claimed in second cycle")
		check(mixer.try_load(player.grabber), "Fresh supply loads in second cycle")
	check(mixer.try_start(), "Second batch starts")
	await frames(310)
	check(mixer.state == MachineBase.State.FINISHED, "Second batch finishes without stale state")
	check(mixer.output_item != null, "Second batch has exactly one occupied output slot")
