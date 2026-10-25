## Crafting at the power console (brief: Milestone 8 item 37): recipes turn ore into parts.
## Parts live in the mine's inventory beside ore, so every cost in the game can name them.
## Pure logic over that inventory.
class_name Crafting
extends RefCounted

## Recipe entries from data/recipes.json: id, name, inputs (item to amount), output.
var recipes: Array


func _init(recipe_list: Array) -> void:
	recipes = recipe_list


## The recipe that makes [param id], or an empty Dictionary.
func find(id: String) -> Dictionary:
	for recipe in recipes:
		if recipe["id"] == id:
			return recipe
	return {}


## True when [param ores] hold the inputs for [param times] runs of recipe [param id].
func can_make(id: String, ores: Dictionary, times: int = 1) -> bool:
	var recipe := find(id)
	if recipe.is_empty():
		return false
	for input in recipe["inputs"]:
		if ores.get(input, 0) < recipe["inputs"][input] * times:
			return false
	return true


## Runs recipe [param id] [param times] times from [param mine]'s inventory. Returns false,
## taking nothing, when the inputs are short.
func make(id: String, mine: Mine, times: int = 1) -> bool:
	if not can_make(id, mine.ores, times):
		return false
	var recipe := find(id)
	for input in recipe["inputs"]:
		mine.take(input, recipe["inputs"][input] * times)
	mine.ores[id] = mine.ores.get(id, 0) + int(recipe["output"]) * times
	mine.changed.emit()
	return true


## Crafts whatever parts [param cost] lacks, recipes inside recipes included, if the ore
## allows. Returns true when [param mine] then covers [param cost]. The pacing simulator
## uses it to play a player who crafts what the next purchase needs.
func make_for(cost: Dictionary, mine: Mine) -> bool:
	for item in cost:
		var short: int = cost[item] - mine.ores.get(item, 0)
		var recipe := find(item)
		if short <= 0 or recipe.is_empty():
			continue
		var times := ceili(short / float(recipe["output"]))
		var inputs := {}
		for input in recipe["inputs"]:
			inputs[input] = recipe["inputs"][input] * times
		if make_for(inputs, mine):
			make(item, mine, times)
	for item in cost:
		if mine.ores.get(item, 0) < cost[item]:
			return false
	return true
