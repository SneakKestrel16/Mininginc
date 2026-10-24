## Draws the shaft around the current block, digs on click, and shows depth and ore counts.
extends VBoxContainer

const BLOCK_SIZE := Vector2(96, 48)
const BLOCKS_ABOVE := 3
const BLOCKS_BELOW := 6
const DUG_COLOR := Color(0.08, 0.09, 0.11)
const UNKNOWN_COLOR := Color(0.55, 0.66, 0.78)
const FROZEN_COLOR := Color(0.82, 0.9, 0.97)
const FROZEN_TEXT_COLOR := Color(0.2, 0.3, 0.42)
const ORE_COLORS := { DigShaft.ROCK: Color(0.42, 0.44, 0.48), "coal": Color(0.12, 0.12, 0.13) }
const CRACK_COLOR := Color(1, 1, 1, 0.35)

## The mine this view shows and digs.
@export var mine: Mine

@onready var _depth_label: Label = %DepthLabel
@onready var _ore_label: Label = %OreLabel
@onready var _shaft: Control = %Shaft


func _ready() -> void:
	_shaft.custom_minimum_size = Vector2(BLOCK_SIZE.x, BLOCK_SIZE.y * (BLOCKS_ABOVE + 1 + BLOCKS_BELOW))
	_shaft.draw.connect(_draw_shaft)
	_shaft.gui_input.connect(_on_shaft_input)
	mine.changed.connect(_refresh)
	_refresh()


func _on_shaft_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		mine.dig()


func _refresh() -> void:
	_depth_label.text = "Depth: %d m" % mine.shaft.depth
	var counts := PackedStringArray()
	for id in mine.ores:
		counts.append("%s: %d" % [id.capitalize(), mine.ores[id]])
	_ore_label.text = "\n".join(counts)
	_shaft.queue_redraw()


func _draw_shaft() -> void:
	var shaft := mine.shaft
	var font := _shaft.get_theme_default_font()
	for row in BLOCKS_ABOVE + 1 + BLOCKS_BELOW:
		var at_depth := shaft.depth - BLOCKS_ABOVE + row
		if at_depth < 0:
			continue
		var rect := Rect2(Vector2(0, row * BLOCK_SIZE.y), BLOCK_SIZE).grow(-1)
		if at_depth < shaft.depth:
			_shaft.draw_rect(rect, DUG_COLOR)
		elif at_depth > shaft.depth or not shaft.revealed:
			_shaft.draw_rect(rect, FROZEN_COLOR if at_depth >= shaft.frozen_from else UNKNOWN_COLOR)
			if at_depth == shaft.depth:
				var mark := "Frozen" if shaft.is_frozen() else "?"
				var ink := FROZEN_TEXT_COLOR if shaft.is_frozen() else Color.WHITE
				_shaft.draw_string(font, rect.position + Vector2(0, 30), mark, HORIZONTAL_ALIGNMENT_CENTER,
						rect.size.x, _shaft.get_theme_default_font_size(), ink)
		else:
			var contents := shaft.block_at(at_depth)
			_shaft.draw_rect(rect, ORE_COLORS.get(contents, ORE_COLORS[DigShaft.ROCK]))
			_shaft.draw_string(font, rect.position + Vector2(0, 30), contents.capitalize(), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)
			# Cracks: one bar per landed hit, across the bottom of the block.
			var progress := shaft.damage / shaft.hardness(at_depth)
			_shaft.draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - 6), Vector2(rect.size.x * progress, 6)), CRACK_COLOR)
		if at_depth == shaft.depth:
			_shaft.draw_rect(rect, Color.WHITE, false, 2.0)
