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
	var mine := economy.mine
	_drill_label.text = drill_line(economy.drill_hits_per_second, mine.drills.size(), mine.working_drills().size(),
			mine.drill_efficiency)


## The console's line on where drill power goes: [param placed] drills, [param working] of
## them still digging, each boring [param efficiency] times the rock per hit (brief item 48).
static func drill_line(hits_per_second: float, placed: int, working: int, efficiency: float) -> String:
	if placed > 0 and working == 0:
		return "Every auto-drill is at bedrock: move the slider to the Heart"
	if working == 0:
		return "Drill power: %.2f hits/s, all to your hand tool while you cut" % hits_per_second
	return "Drill power: %.2f hits/s, shared by %d auto-drill%s (they bore %sx per hit) and your hand tool while you cut" % [
			hits_per_second, working, "" if working == 1 else "s", Mine.number_text(efficiency)]
