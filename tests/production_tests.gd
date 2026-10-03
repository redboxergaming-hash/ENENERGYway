extends SceneTree
## Full six-can order plus inventory and settlement edge cases in the actual factory.
var checks: int = 0
var failures: int = 0
var scene: Node3D
var player: FactoryPlayer
var filler: CanFiller
var orders: OrderManager

func _initialize() -> void:
	_run.call_deferred()
	var watchdog := Timer.new()
	watchdog.one_shot = true
	watchdog.wait_time = 60.0
	watchdog.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child.call_deferred(watchdog)
	watchdog.timeout.connect(func():
		push_error("Production suite exceeded 60 seconds")
		quit(1))
	watchdog.start.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if ok:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame

func press(action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(2)

func move_and_aim(at: Vector3, target: Vector3) -> void:
	var shift := at - player.global_position
	player.global_position = at
	player.velocity = Vector3.ZERO
	if is_instance_valid(player.grabber.held_item):
		player.grabber.held_item.global_position += shift
	player.camera.look_at(target, Vector3.UP)
	await frames(4)

func _run() -> void:
	scene = load("res://factory/factory.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.player
	filler = scene.filler
	orders = scene.orders
	await frames(30)
	check(orders.active and orders.order_number == 1 and orders.money == 0, "Shift begins with first order and zero money")
	check(orders.specification.quantity == 6 and orders.specification.deadline == 180, "Order specifies six cans and a three-minute deadline")
	check(not filler.try_start(), "Filler cannot create cans without inputs")
	check(not orders.accept(player.grabber), "Empty-handed delivery cannot count")
	for ingredient: CarryableItem in scene.supplies:
		player.grabber.grab(ingredient)
		check(not filler.try_load(player.grabber), "Filler rejects raw ingredients without consuming them")
		check(scene.mixer.try_load(player.grabber), "Ingredient remains available for mixer")
	check(scene.mixer.try_start(), "Mixer starts the real production batch")
	await frames(310)
	var batch: CarryableItem = scene.mixer.output_item
	check(batch.servings == 6 and batch.definition.kind == ItemDefinition.Kind.BATCH, "Mixer output contains exactly six servings")
	await move_and_aim(Vector3(3.05, 0.05, -0.6), batch.global_position)
	await press(&"p1_interact")
	check(player.grabber.held_item == batch, "Production batch can be picked up from mixer tray")
	await move_and_aim(Vector3(6.1, 0.05, -0.85), filler.global_position + Vector3(0, 1.2, 0.35))
	check(player.interaction.target == filler, "Filler is reachable via camera targeting")
	await press(&"p1_use")
	check(filler.servings_remaining == 6 and player.grabber.held_item == null, "Use action transfers the physical batch once")
	check(not filler.try_start(), "Liquid alone cannot produce cans")
	# Complete the loading phase via actual player actions and the dispenser.
	for i in 6:
		await move_and_aim(Vector3(6.8, 0.05, 2.1), scene.get_node("CanSupply").global_position + Vector3(0, 1.0, 0.54))
		check(player.interaction.target == scene.get_node("CanSupply"), "Can dispenser can be targeted")
		await press(&"p1_interact")
		var can := player.grabber.held_item
		check(can != null and can.definition.kind == ItemDefinition.Kind.EMPTY_CAN, "Dispenser gives a physical empty can")
		check(not orders.accept(player.grabber), "Delivery rejects an empty can")
		await move_and_aim(Vector3(6.1, 0.05, -0.85), filler.global_position + Vector3(0, 1.2, 0.35))
		await press(&"p1_use")
		check(filler.empty_cans == i + 1, "Filler accounts for each empty can once")
	var extra := _item(ItemCatalog.EMPTY_CAN)
	player.grabber.grab(extra)
	check(not filler.try_load(player.grabber) and player.grabber.held_item == extra, "Seventh can is rejected and retained")
	player.grabber.consume_held()
	await press(&"p1_context")
	check(filler.state == MachineBase.State.PROCESSING, "Context action starts filling")
	check(not filler.try_start(), "Repeated fill command cannot duplicate work")
	var time_before := orders.time_remaining
	var fill_before := filler.elapsed
	scene.set_paused(true)
	await frames(12)
	check(is_equal_approx(time_before, orders.time_remaining) and is_equal_approx(fill_before, filler.elapsed), "Pause freezes both deadline and production")
	scene.set_paused(false)
	await frames(380)
	check(filler.outputs.size() == 6, "One batch and six empties produce exactly six physical cans")
	check(filler.empty_cans == 0 and filler.servings_remaining == 0, "Each output consumes exactly one empty and one serving")
	check(not filler.try_start(), "Empty reservoir cannot refill itself")
	check(filler.outputs.all(func(c): return c.global_position.y > 0.85), "All six cans stay on the output tray")
	for i in 6:
		await move_and_aim(Vector3(4.0, 0.05, -0.6), filler.output.global_position)
		var remaining := filler.outputs.duplicate()
		remaining.sort_custom(func(a, b): return a.global_position.distance_squared_to(player.camera.global_position) < b.global_position.distance_squared_to(player.camera.global_position))
		if remaining.is_empty():
			check(false, "Expected another filled can")
			quit(1)
			return
		player.camera.look_at(remaining[0].global_position, Vector3.UP)
		await frames(3)
		var can := player.interaction.target as CarryableItem
		check(can != null and can in filler.outputs, "Filled can can be selected from tray")
		if can == null:
			quit(1)
			return
		await press(&"p1_interact")
		check(player.grabber.held_item == can, "Filled can can be carried to delivery")
		await move_and_aim(Vector3(6.2, 0.05, 5.35), scene.get_node("Delivery").global_position + Vector3(0, 0.8, 0.65))
		check(player.interaction.target == scene.get_node("Delivery"), "Delivery desk is reachable")
		await press(&"p1_interact")
		check(orders.delivered == i + 1, "Matching can is delivered exactly once")
	check(orders.money == 420 and orders.orders_completed == 1 and not orders.active, "Six deliveries settle once for $420")
	check(not orders.accept(player.grabber) and orders.money == 420, "Repeated delivery cannot pay again")
	check(filler.outputs.is_empty(), "Collected outputs free every filler slot")
	await frames(190)
	check(orders.active and orders.order_number == 2 and orders.delivered == 0, "Next order appears automatically")
	check(orders.money == 420 and orders.time_remaining > 175, "Next order preserves money and refreshes deadline")
	var wrong := _item(ItemCatalog.FILLED_CAN)
	wrong.batch_recipe = scene.mixer.recipe.duplicate()
	wrong.batch_recipe.id = &"wrong_recipe"
	player.grabber.grab(wrong)
	check(not orders.accept(player.grabber), "Different product cannot satisfy Tropical Shock order")
	player.grabber.consume_held()
	orders.time_remaining = 0.01
	await frames(3)
	check(not orders.active and orders.money == 320, "Timeout applies $100 penalty once")
	await frames(30)
	check(orders.money == 320, "Expired order cannot charge repeated penalties")
	await frames(160)
	check(orders.active and orders.order_number == 3, "Timeout recovers into a fresh order")
	scene.restart()
	await frames(5)
	scene = current_scene
	check(scene.orders.money == 0 and scene.orders.order_number == 1, "Restart resets economy and order state")
	check(scene.filler.outputs.is_empty() and scene.filler.servings_remaining == 0, "Restart clears machine inventories")
	scene.queue_free()
	await frames(3)
	print("PRODUCTION RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _item(definition: ItemDefinition) -> CarryableItem:
	var item := load("res://items/carryable_item.tscn").instantiate() as CarryableItem
	item.definition = definition
	item.batch_recipe = scene.mixer.recipe
	item.position = player.grabber.anchor.global_position
	scene.add_child(item)
	return item
