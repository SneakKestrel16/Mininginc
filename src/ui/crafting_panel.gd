## The crafting panel in the power console's overlay (brief: Milestone 8 item 37): one row
## per recipe with what it takes and makes, and buttons to craft one or five. Built in code
## from data/recipes.json, so a new recipe needs no scene edit.
class_name CraftingPanel
extends PanelContainer

## The economy whose recipes this panel runs.
@export var economy: Economy

var _rows: Dictionary = {}


func _ready() -> void:
	custom_minimum_size.x = 420
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	margin.add_child(list)
	var title := Label.new()
	title.text = "Crafting"
	list.add_child(title)
	for recipe in economy.crafting.recipes:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		list.add_child(row)
		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var buttons := []
		for times in [1, 5]:
			var craft := Button.new()
			craft.text = "x%d" % times
			craft.custom_minimum_size.x = 48
			craft.pressed.connect(_craft.bind(recipe["id"], times))
			row.add_child(craft)
			buttons.append(craft)
		_rows[recipe["id"]] = [info, buttons]
	economy.mine.changed.connect(_refresh)
	visibility_changed.connect(_refresh)
	_refresh()


func _craft(id: String, times: int) -> void:
	economy.crafting.make(id, economy.mine, times)
	_refresh()


func _refresh() -> void:
	var ores := economy.mine.ores
	for recipe in economy.crafting.recipes:
		var id: String = recipe["id"]
		var parts := PackedStringArray()
		for input in recipe["inputs"]:
			parts.append("%d %s" % [recipe["inputs"][input], input.replace("_", " ")])
		_rows[id][0].text = "%s  (have %d)\n%s -> %d" % [recipe["name"], ores.get(id, 0), ", ".join(parts), recipe["output"]]
		_rows[id][1][0].disabled = not economy.crafting.can_make(id, ores, 1)
		_rows[id][1][1].disabled = not economy.crafting.can_make(id, ores, 5)
