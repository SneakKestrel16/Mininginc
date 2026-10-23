## Shows the furnace's fuel and output, and feeds it coal by hand.
extends PanelContainer

## The economy whose furnace this panel shows.
@export var economy: Economy

@onready var _state_label: Label = %StateLabel
@onready var _fuel_bar: ProgressBar = %FuelBar
@onready var _fuel_label: Label = %FuelLabel
@onready var _feed_button: Button = %FeedButton


func _ready() -> void:
	_fuel_bar.max_value = economy.furnace.capacity
	_feed_button.pressed.connect(economy.feed_furnace)
	economy.ticked.connect(_refresh)
	economy.mine.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var furnace := economy.furnace
	var coal: int = economy.mine.ores.get("coal", 0)
	_state_label.text = "Furnace: burning, %.1f/s" % economy.power_per_second if furnace.is_burning() \
			else "Furnace: out of fuel"
	_fuel_bar.value = furnace.fuel_level()
	_fuel_label.text = "Fuel %.1f / %d" % [furnace.fuel_level(), furnace.capacity]
	_feed_button.text = "Feed coal (%d)" % coal
	_feed_button.disabled = coal == 0 or furnace.space() == 0
