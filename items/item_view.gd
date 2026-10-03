extends Node3D

func _ready() -> void:
	var item := get_parent() as CarryableItem
	var scene: PackedScene = item.ingredient.visual if item.ingredient else item.definition.visual
	if scene:
		add_child(scene.instantiate())
	if item.ingredient:
		Graybox.label(self, item.ingredient.display_name.replace(" FLAVOR", ""), Vector3(0, 0.01, 0.254), 13, Color("253744"))
	elif item.definition.kind == ItemDefinition.Kind.BATCH:
		Graybox.label(self, "TROPICAL\nSHOCK", Vector3(0, 0.05, 0.344), 15, Color("253744"))
		Graybox.label(self, "%d SERVINGS" % item.servings, Vector3(0, -0.09, 0.345), 9, Color("253744"))
