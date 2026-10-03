extends Node3D
var status: Label3D
var counter: Label3D
var can_visuals: Node3D
var filler: CanFiller

func _ready() -> void:
	filler = get_parent() as CanFiller
	add_child(preload("res://art/models/filler.glb").instantiate())
	status = Graybox.label(self, "LOAD A BATCH", Vector3(0, 1.45, 0.28), 17, Color("a8dfc3"))
	counter = Graybox.label(self, "0 / 6", Vector3(0, 1.13, 0.28), 14, Color("f5e5bd"))
	can_visuals = Node3D.new()
	add_child(can_visuals)
	filler.contents_changed.connect(_update)
	filler.state_changed.connect(func(_a, _b): _update())

func _update() -> void:
	status.text = "FILLING..." if filler.state == MachineBase.State.PROCESSING else "%d SERVINGS" % filler.servings_remaining
	counter.text = "%d / 6 CANS LOADED" % filler.empty_cans
	for child in can_visuals.get_children():
		child.queue_free()
	for index in filler.empty_cans:
		var can := preload("res://art/models/empty_can.glb").instantiate() as Node3D
		can_visuals.add_child(can)
		can.position = Vector3(-0.8 + index * 0.32, 0.99, 0.53)
