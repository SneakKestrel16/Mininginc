## Shows the power split slider for an [Economy].
extends PanelContainer

## The economy this panel shows and steers.
@export var economy: Economy

@onready var _power_label: Label = %PowerLabel
@onready var _split_slider: HSlider = %SplitSlider
@onready var _share_label: Label = %ShareLabel
@onready var _drill_label: Label = %DrillLabel


func _ready() -> void:
	_split_slider.value = economy.split.heart_share * 100.0
	_split_slider.value_changed.connect(_on_split_changed)
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
	var drills := economy.mine.working_drills().size()
	_drill_label.text = "Drill power: %.2f hits/s, shared by your hand tool%s" % [economy.drill_hits_per_second,
			"" if drills == 0 else " and %d auto-drill%s" % [drills, "" if drills == 1 else "s"]]
