extends Node3D
var orders: OrderManager
var label: Label3D

func _ready() -> void:
	Graybox.box(self, Vector3(3.45, 1.3, 0.12), Vector3.ZERO, Color("253744"))
	label = Graybox.label(self, "", Vector3(0, 0, 0.08), 24, Color("f5df9b"))

func _process(_delta: float) -> void:
	var seconds := ceili(orders.time_remaining)
	label.text = "GYM BRO GMBH\n%d / 6 TROPICAL SHOCK\n%02d:%02d   /   $420" % [orders.delivered, seconds / 60, seconds % 60]
