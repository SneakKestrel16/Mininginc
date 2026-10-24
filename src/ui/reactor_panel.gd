## Shows the fission reactor: builds it with copper, then feeds it uranium and shows its heat.
extends PanelContainer

## The economy whose reactor this panel shows.
@export var economy: Economy

@onready var _state_label: Label = %StateLabel
@onready var _build_button: Button = %BuildButton
@onready var _running: Control = %Running
@onready var _fuel_label: Label = %FuelLabel
@onready var _heat_bar: ProgressBar = %HeatBar
@onready var _heat_label: Label = %HeatLabel
@onready var _feed_button: Button = %FeedButton


func _ready() -> void:
	_heat_bar.max_value = economy.reactor.heat_limit
	_build_button.pressed.connect(economy.build_reactor)
	_feed_button.pressed.connect(economy.feed_reactor)
	economy.ticked.connect(_refresh)
	economy.mine.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var reactor := economy.reactor
	var ores := economy.mine.ores
	_build_button.visible = not economy.reactor_built
	_running.visible = economy.reactor_built
	if not economy.reactor_built:
		_state_label.text = "Fission reactor: not built"
		_build_button.text = "Build (%d / %d copper)" % [ores.get("copper", 0), economy.reactor_cost]
		_build_button.disabled = not economy.can_build_reactor()
		return
	if reactor.is_running():
		_state_label.text = "Fission reactor: running, %.1f/s" % economy.reactor_output
	else:
		_state_label.text = "Fission reactor: out of uranium"
	_fuel_label.text = "Uranium %.1f / %d" % [reactor.core.fuel_level(), reactor.core.capacity]
	_heat_bar.value = reactor.heat
	_heat_label.text = "Heat %.0f / %.0f" % [reactor.heat, reactor.heat_limit]
	_feed_button.text = "Feed uranium (%d)" % ores.get("uranium", 0)
	_feed_button.disabled = ores.get("uranium", 0) == 0 or reactor.core.space() == 0
