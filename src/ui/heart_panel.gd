## Shows the Heart's stage, its latest story beat, and the meter toward the next stage.
extends PanelContainer

## The economy whose Heart this panel shows.
@export var economy: Economy

@onready var _stage_label: Label = %StageLabel
@onready var _line_label: Label = %LineLabel
@onready var _heart_bar: ProgressBar = %HeartBar
@onready var _heart_label: Label = %HeartLabel


func _ready() -> void:
	economy.ticked.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var heart := economy.heart
	var count := heart.stages.size()
	if heart.stage == 0:
		_stage_label.text = "The Heart sleeps  (stage 0 / %d)" % count
		_line_label.text = "Something enormous lies under the ice. It hums when you send it power."
	else:
		_stage_label.text = "Heart: %s  (stage %d / %d)" % [heart.current()["name"], heart.stage, count]
		_line_label.text = heart.current()["line"]
	if heart.is_awake():
		_heart_bar.max_value = 1.0
		_heart_bar.value = 1.0
		_heart_label.text = "Every stage reached. Nothing more wakes in this build."
	else:
		_heart_bar.max_value = heart.threshold()
		_heart_bar.value = heart.progress
		_heart_label.text = "Next: %s  %.0f / %.0f" % [heart.stages[heart.stage]["name"], heart.progress, heart.threshold()]
