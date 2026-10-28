## The upgrade shop in the power console's overlay (brief: Milestone 5 item 28): one row per
## upgrade with its level, what it gives now, and a button to buy the next level. Built in
## code from data/upgrades.json, so a new upgrade needs no scene edit.
class_name UpgradePanel
extends PanelContainer

## The economy whose upgrades this panel sells.
@export var economy: Economy

var _rows: Dictionary = {}


func _ready() -> void:
	custom_minimum_size.x = 400
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)  # nine rows fit a 648 px window
	margin.add_child(list)
	var title := Label.new()
	title.text = "Upgrades"
	list.add_child(title)
	for upgrade in economy.upgrades.defs:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		list.add_child(row)
		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var buy := Button.new()
		buy.custom_minimum_size.x = 150
		buy.pressed.connect(_buy.bind(upgrade["id"]))
		row.add_child(buy)
		_rows[upgrade["id"]] = [info, buy]
	economy.mine.changed.connect(_refresh)
	visibility_changed.connect(_refresh)
	_refresh()


## What [param upgrade] gives at [param level], as its describe line shows it.
static func effect_text(upgrade: Dictionary, level: int) -> String:
	# Rounded first: 0.3 x 3 x 100 is 89.99999999999999 in floats, and %d would show 89.
	return upgrade["describe"] % (roundf(upgrade["per_level"] * level * upgrade["shown_scale"] * 1000.0) / 1000.0)


func _buy(id: String) -> void:
	economy.buy_upgrade(id)
	_refresh()


func _refresh() -> void:
	var upgrades := economy.upgrades
	for upgrade in upgrades.defs:
		var id: String = upgrade["id"]
		var level: int = upgrades.levels[id]
		var info: Label = _rows[id][0]
		var buy: Button = _rows[id][1]
		info.text = "%s  %d/%d\n%s" % [upgrade["name"], level, upgrade["max_level"], effect_text(upgrade, level)]
		if upgrades.is_maxed(id):
			buy.text = "Maxed"
		else:
			buy.text = "Buy: " + Mine.cost_text(upgrades.cost(id))
		buy.disabled = not upgrades.can_buy(id, economy.mine.ores)
