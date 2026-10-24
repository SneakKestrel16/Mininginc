## The HUD over the first-person view (brief: Milestone 3D item 19): inventory, total
## power, the Heart's stage and meter, and each stage's story line as it is reached.
extends CanvasLayer

## Seconds a stage's line stays on screen before it fades.
const LINE_SECONDS := 8.0

## The economy this HUD reports.
@export var economy: Economy

var _line_left := 0.0

@onready var _inventory: Label = %Inventory
@onready var _power: Label = %Power
@onready var _stage: Label = %Stage
@onready var _meter: ProgressBar = %Meter
@onready var _line: Label = %Line


func _ready() -> void:
	economy.stage_reached.connect(_on_stage_reached)
	_line.modulate.a = 0.0


func _process(delta: float) -> void:
	var ores := economy.mine.ores
	var counts := PackedStringArray()
	for id in ores:
		counts.append("%s %d" % [id.capitalize(), ores[id]])
	_inventory.text = "   ".join(counts)
	_power.text = "Power %.1f/s" % economy.power_per_second
	var heart := economy.heart
	var count := heart.stages.size()
	var stage_name: String = "asleep" if heart.stage == 0 else heart.current()["name"]
	if heart.is_awake():
		_stage.text = "Heart: %s (%d/%d) — every stage reached" % [stage_name, heart.stage, count]
		_meter.value = 1.0
		_meter.max_value = 1.0
	else:
		_stage.text = "Heart: %s (%d/%d) — next %s %.0f / %.0f" % [stage_name, heart.stage, count,
				heart.stages[heart.stage]["name"], heart.progress, heart.threshold()]
		_meter.max_value = heart.threshold()
		_meter.value = heart.progress
	if _line_left > 0.0:
		_line_left -= delta
		_line.modulate.a = clampf(_line_left, 0.0, 1.0)


func _on_stage_reached(index: int) -> void:
	_line.text = "%s\n%s" % [economy.heart.stages[index]["name"], economy.heart.stages[index]["line"]]
	_line_left = LINE_SECONDS
