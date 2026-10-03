class_name RecipeData
extends Resource

@export var id: StringName
@export var display_name: String
@export var ingredients: Array[IngredientData] = []
@export var units: Array[int] = []
@export_range(0.1, 120.0) var mix_seconds: float = 5.0
@export_range(1, 48) var servings: int = 6
@export var color: Color = Color("ffb733")

func is_valid() -> bool:
	if id == &"" or ingredients.is_empty() or ingredients.size() != units.size():
		return false
	var seen: Array[StringName] = []
	for index in ingredients.size():
		if ingredients[index] == null or units[index] < 1:
			return false
		if ingredients[index].id == &"" or ingredients[index].id in seen:
			return false
		seen.append(ingredients[index].id)
	return true

func required_units(ingredient_id: StringName) -> int:
	for index in ingredients.size():
		if ingredients[index].id == ingredient_id:
			return units[index]
	return 0

func matches(contents: Dictionary) -> bool:
	if not is_valid() or contents.size() != ingredients.size():
		return false
	for index in ingredients.size():
		if contents.get(ingredients[index].id, 0) != units[index]:
			return false
	return true
