## Shows the steam turbine: builds it with copper, then feeds it coal and melts ice for it.
extends PanelContainer

## The economy whose turbine this panel shows.
@export var economy: Economy

@onready var _state_label: Label = %StateLabel
@onready var _build_button: Button = %BuildButton
@onready var _running: Control = %Running
@onready var _fuel_label: Label = %FuelLabel
@onready var _water_bar: ProgressBar = %WaterBar
@onready var _water_label: Label = %WaterLabel
@onready var _feed_button: Button = %FeedButton
@onready var _melt_button: Button = %MeltButton


func _ready() -> void:
	_water_bar.max_value = economy.turbine.water_capacity
	_build_button.pressed.connect(economy.build_turbine)
	_feed_button.pressed.connect(economy.feed_turbine)
	_melt_button.pressed.connect(economy.melt_ice)
	economy.ticked.connect(_refresh)
	economy.mine.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var turbine := economy.turbine
	var ores := economy.mine.ores
	_build_button.visible = not economy.turbine_built
	_running.visible = economy.turbine_built
	if not economy.turbine_built:
		_state_label.text = "Steam turbine: not built"
		_build_button.text = "Build (%d / %d copper)" % [ores.get("copper", 0), economy.turbine_cost]
		_build_button.disabled = not economy.can_build_turbine()
		return
	if turbine.is_running():
		_state_label.text = "Steam turbine: running, %.1f/s" % economy.turbine_output
	elif not turbine.boiler.is_burning():
		_state_label.text = "Steam turbine: out of coal"
	else:
		_state_label.text = "Steam turbine: out of water"
	_fuel_label.text = "Coal %.1f / %d" % [turbine.boiler.fuel_level(), turbine.boiler.capacity]
	_water_bar.value = turbine.water
	_water_label.text = "Water %.0f / %.0f" % [turbine.water, turbine.water_capacity]
	_feed_button.text = "Feed coal (%d)" % ores.get("coal", 0)
	_feed_button.disabled = ores.get("coal", 0) == 0 or turbine.boiler.space() == 0
	_melt_button.text = "Melt ice (%d)" % ores.get("ice", 0)
	_melt_button.disabled = ores.get("ice", 0) == 0 or turbine.ice_space() == 0
