## The launch (brief: Milestone 7 items 33–34): the screen fades while the player rises with
## the Heart, the Heart's closing words play, and the run's Resonance is shown before a new
## moon begins. Built in code: one overlay, no camera work.
class_name Ending
extends CanvasLayer

## Seconds the fade to black takes.
const FADE_SECONDS := 3.0
## Seconds each closing line stays.
const LINE_SECONDS := 4.0

@export var economy: Economy
@export var player: Player
## Starts the new moon when the player is ready.
@export var save_game: SaveGame

var _shade := ColorRect.new()
var _text := Label.new()
var _again := Button.new()


func _ready() -> void:
	layer = 4
	visible = false
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shade.color = Color(0, 0, 0, 0)
	add_child(_shade)
	_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 26)
	add_child(_text)
	_again.text = "Begin a new moon"
	_again.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_again.position.y -= 120
	_again.visible = false
	_again.pressed.connect(func() -> void: save_game.new_moon())
	add_child(_again)


## Plays the launch. The run is over from here: the next step is a new moon.
func play() -> void:
	if visible:
		return
	visible = true
	player.hint_blocked = true
	player.set_controls(false)
	player.noclip = true  # rises up through the rock with the Heart
	player.flying = true
	var rise := create_tween().set_parallel()
	rise.tween_property(player, "global_position:y", player.global_position.y + 120.0, FADE_SECONDS * 2.0) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	rise.tween_property(_shade, "color:a", 1.0, FADE_SECONDS)
	await get_tree().create_timer(FADE_SECONDS).timeout
	var wake: Dictionary = economy.heart.stages[-1]
	for line in wake.get("launch_lines", []):
		_text.text = line
		await get_tree().create_timer(LINE_SECONDS).timeout
	var total := economy.resonance + 1
	_text.text = "Resonance +1 (now %d)\nOn every new moon, every generator runs %d%% stronger." % [total,
			roundi(total * economy.resonance_power_bonus * 100.0)]
	_again.visible = true
