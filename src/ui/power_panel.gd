## Shows the power split slider and the Heart meter for an [Economy].
extends PanelContainer

## The economy this panel shows and steers.
@export var economy: Economy

@onready var _power_label: Label = %PowerLabel
@onready var _split_slider: HSlider = %SplitSlider
@onready var _share_label: Label = %ShareLabel
@onready var _drill_label: Label = %DrillLabel
@onready var _heart_bar: ProgressBar = %HeartBar
@onready var _heart_label: Label = %HeartLabel


func _ready() -> void:
	_split_slider.value = economy.split.heart_share * 100.0
	_split_slider.value_changed.connect(_on_split_changed)
	_heart_bar.max_value = economy.split.heart_threshold
	economy.ticked.connect(_refresh)
	_refresh()


func _on_split_changed(value: float) -> void:
	economy.split.heart_share = value / 100.0
	_refresh()


func _refresh() -> void:
	var split := economy.split
	_power_label.text = "Power: %.1f/s" % economy.power_per_second
	_share_label.text = "Drills %.1f/s  |  Heart %.1f/s" % [
		economy.power_per_second * (1.0 - split.heart_share),
		economy.power_per_second * split.heart_share,
	]
	_drill_label.text = "Drill speed: %.2f hits/s" % economy.drill_hits_per_second
	_heart_bar.value = split.heart_progress
	_heart_label.text = "Heart: %.0f / %.0f" % [split.heart_progress, split.heart_threshold]
