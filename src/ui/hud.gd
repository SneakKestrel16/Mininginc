## The HUD over the first-person view (brief: Milestone 3D item 19): inventory, total
## power, the Heart's stage and meter, and each stage's story line as it is reached.
extends CanvasLayer

## Seconds a stage's line stays on screen before it fades.
const LINE_SECONDS := 8.0
## Seconds each of a speaking stage's lines stays on screen.
const SPOKEN_SECONDS := 5.0
## Seconds a stratum's banner stays on screen.
const STRATUM_SECONDS := 4.0
## Seconds the banner for a vault broken into stays on screen.
const VAULT_SECONDS := 3.0

## The economy this HUD reports.
@export var economy: Economy
## Whose hand tool speed it shows.
@export var player: Player
## The buried Heart: the HUD says roughly how far it is.
@export var heart: Node3D
## Tells when the player enters a new stratum.
@export var depth_sense: DepthSense

var _line_left := 0.0
# Ore gained from the last scoops, shown under the crosshair, and seconds it has left.
var _gain := Label.new()
var _gain_left := 0.0
# Spoken lines still to show after the current one, oldest first.
var _queue: Array = []

@onready var _inventory: Label = %Inventory
@onready var _power: Label = %Power
@onready var _stage: Label = %Stage
@onready var _meter: ProgressBar = %Meter
@onready var _line: Label = %Line


func _ready() -> void:
	economy.stage_reached.connect(_on_stage_reached)
	_line.modulate.a = 0.0
	_gain.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_gain.position.y += 28
	_gain.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_gain.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gain.add_theme_color_override("font_color", Color(1.0, 0.8, 0.35))
	_gain.add_theme_constant_override("outline_size", 6)
	_gain.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(_gain)
	player.scooped.connect(_on_scooped)
	if depth_sense:
		depth_sense.stratum_entered.connect(_on_stratum_entered)
	economy.mine.world.vault_opened.connect(_on_vault_opened)


func _process(delta: float) -> void:
	var ores := economy.mine.ores
	var counts := PackedStringArray()
	for id in ores:
		if ores[id] > 0:
			counts.append("%s %d" % [id.capitalize(), ores[id]])
	_inventory.text = "   ".join(counts) if not counts.is_empty() else "Inventory empty"
	_power.text = "Power %.1f/s   Hand tool %.1f hits/s" % [economy.power_per_second, player.hand_rate()]
	if economy.resonance > 0:
		_power.text += "   Resonance %d (+%d%% power)" % [economy.resonance,
				roundi(economy.resonance * economy.resonance_power_bonus * 100.0)]
	if heart:
		var to_heart := heart.global_position - player.global_position
		# Rounded to 5 m: a sense of direction, not a map.
		_power.text += "
Heart: about %d m %s, %d m across" % [snappedi(absf(to_heart.y), 5),
				"down" if to_heart.y <= 0.0 else "up", snappedi(Vector2(to_heart.x, to_heart.z).length(), 5)]
	var world := economy.mine.world
	if not world.strata.is_empty():
		var depth := maxi(-floori(player.global_position.y), 0)
		_power.text += "
Depth %d m — %s" % [depth, world.strata[world.stratum_at(depth)]["name"]]
	# Once the Heart has Sight it senses the nearest vault: how far, never what or which way.
	if economy.heart.has_effect("ore_sight"):
		var near := world.vaults_near(player.global_position, world.vault_sight_range)
		if not near.is_empty():
			_power.text += "\n" + vault_line(player.global_position, near[0]["center"])
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
	if not _spoken().is_empty():
		_stage.text += "   [L] hear it again"
	_gain_left -= delta
	_gain.modulate.a = clampf(_gain_left * 2.0, 0.0, 1.0)
	if _line_left > 0.0:
		_line_left -= delta
		_line.modulate.a = clampf(_line_left, 0.0, 1.0)
	elif not _queue.is_empty():
		_show(_queue.pop_front(), SPOKEN_SECONDS)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_L:
		_queue = _spoken()
		_line_left = 0.0


# Ore only: rock and crust are what every scoop gives.
func _on_scooped(collected: Dictionary) -> void:
	var parts := PackedStringArray()
	for what in collected:
		if what in economy.mine.ores:
			parts.append("+%d %s" % [collected[what], what])
	if not parts.is_empty():
		_gain.text = "  ".join(parts)
		_gain_left = 1.5


## The HUD line for the nearest vault, seen from [param from]: its distance and how far below
## or above, rounded to 5 m like the Heart's.
static func vault_line(from: Vector3, vault: Vector3) -> String:
	var offset := vault - from
	var height := snappedi(absf(offset.y), 5)
	return "Vault: about %d m away, %s" % [snappedi(offset.length(), 5),
			"level with you" if height == 0 else "%d m %s" % [height, "down" if offset.y < 0.0 else "up"]]


func _on_vault_opened(_index: int, ore: String) -> void:
	_show("A vault breaks open\nIts walls are %s" % ore, VAULT_SECONDS)


func _on_stratum_entered(index: int) -> void:
	var stratum: Dictionary = economy.mine.world.strata[index]
	_show("%s
%s" % [stratum["name"], stratum["line"]], STRATUM_SECONDS)


func _on_stage_reached(index: int) -> void:
	var stage: Dictionary = economy.heart.stages[index]
	_show("%s\n%s" % [stage["name"], stage["line"]], LINE_SECONDS)
	if stage.has("lines"):
		_queue = stage["lines"].duplicate()


# Spoken lines of every stage reached so far, in order; from the stage index alone.
func _spoken() -> Array:
	var lines := []
	for i in economy.heart.stage:
		lines.append_array(economy.heart.stages[i].get("lines", []))
	return lines


func _show(text: String, seconds: float) -> void:
	_line.text = text
	_line_left = seconds
