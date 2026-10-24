## Upgrades bought with ore at the power console (brief: Milestone 5 items 28–29). Pure
## logic: its state is a level per upgrade, and every effect follows from the levels, so a
## save needs no more.
class_name Upgrades
extends RefCounted

## Upgrade entries from data/upgrades.json: id, name, effect, per_level, max_level, cost
## (ore id to amount at level 0), cost_growth, describe, shown_scale.
var defs: Array
## Upgrade id to levels bought.
var levels: Dictionary = {}


func _init(upgrade_list: Array) -> void:
	defs = upgrade_list
	for upgrade in defs:
		levels[upgrade["id"]] = 0


## The entry for upgrade [param id], or an empty Dictionary.
func find(id: String) -> Dictionary:
	for upgrade in defs:
		if upgrade["id"] == id:
			return upgrade
	return {}


## True once upgrade [param id] is at its cap.
func is_maxed(id: String) -> bool:
	return levels.get(id, 0) >= int(find(id)["max_level"])


## Ore the next level of [param id] costs: each ore's base amount times growth per level.
func cost(id: String) -> Dictionary:
	var upgrade := find(id)
	var price := {}
	for ore in upgrade["cost"]:
		price[ore] = ceili(upgrade["cost"][ore] * pow(upgrade["cost_growth"], levels.get(id, 0)))
	return price


## True when [param ores] cover the next level of [param id] and it is not at its cap.
func can_buy(id: String, ores: Dictionary) -> bool:
	if is_maxed(id):
		return false
	var price := cost(id)
	for ore in price:
		if ores.get(ore, 0) < price[ore]:
			return false
	return true


## Takes the next level's ore from [param mine] and raises [param id] one level.
## Returns false, taking nothing, when it cannot be bought.
func buy(id: String, mine: Mine) -> bool:
	if not can_buy(id, mine.ores):
		return false
	var price := cost(id)
	for ore in price:
		mine.take(ore, price[ore])
	levels[id] += 1
	return true


## Sum of every bought level's effect named [param effect].
func effect(effect_name: String) -> float:
	var total := 0.0
	for upgrade in defs:
		if upgrade["effect"] == effect_name:
			total += upgrade["per_level"] * levels.get(upgrade["id"], 0)
	return total


## Levels as saved; ids the data no longer has are dropped on load.
func load_levels(saved: Dictionary) -> void:
	for id in levels:
		levels[id] = clampi(int(saved.get(id, 0)), 0, int(find(id)["max_level"]))
