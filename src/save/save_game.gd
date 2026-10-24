## Saves the game to user:// on a timer and on quit, loads it on start, and plays the
## time spent away as offline progress (brief: MVP feature 7). user:// is outside the
## launcher's folder, so updates never touch saves.
class_name SaveGame
extends Node

## Bumped when the save layout changes, so a later build can migrate older saves.
const FORMAT_VERSION := 1
const CONFIG_PATH := "res://data/save.json"

@export var economy: Economy
@export var mine: Mine
## Shows what was earned while away.
@export var away_dialog: AcceptDialog

## Where the save lives. Checks and probes point it elsewhere so they never touch a real save.
var save_path := "user://savegame.json"

var _offline_cap: float
var _offline_step: float


func _ready() -> void:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary or not config.has_all(["autosave_seconds", "offline_cap_seconds", "offline_step_seconds"]) \
			or config["offline_step_seconds"] <= 0.0:
		push_error("Cannot read %s; saving is off this session" % CONFIG_PATH)
		OS.alert("Cannot read %s. The game will run, but nothing will be saved." % CONFIG_PATH, "Heartwake")
		return
	_offline_cap = config["offline_cap_seconds"]
	_offline_step = config["offline_step_seconds"]
	load_game()
	var timer := Timer.new()
	timer.wait_time = config["autosave_seconds"]
	timer.timeout.connect(save_game)
	add_child(timer)
	timer.start()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and _offline_step > 0.0:
		save_game()


## Writes the current state to [member save_path], through a temporary file so a crash
## mid-write never leaves a half-written save.
func save_game() -> void:
	var temp := save_path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s (error %d)" % [temp, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(capture(economy, mine, Time.get_unix_time_from_system()), "\t"))
	file.close()
	DirAccess.rename_absolute(temp, save_path)


## Loads [member save_path] if there is one, then plays the time since it was saved.
## A save that cannot be read is moved aside, never overwritten, and a new game starts.
func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	var problem := validate(data)
	if problem != "":
		var kept := "%s.unreadable-%d.json" % [save_path.get_basename(), Time.get_unix_time_from_system()]
		DirAccess.rename_absolute(save_path, kept)
		push_error("Save unreadable (%s); kept as %s, starting a new game" % [problem, kept])
		_show("Your save could not be read (%s).\nA new game has started; the old file is kept as\n%s" % [problem, ProjectSettings.globalize_path(kept)])
		return
	apply(data, economy, mine)
	var away := clampf(Time.get_unix_time_from_system() - data["saved_at"], 0.0, _offline_cap)
	if away >= _offline_step:
		var before := snapshot(economy, mine)
		economy.advance(away, _offline_step)
		_show(summary(before, snapshot(economy, mine), away))


func _show(text: String) -> void:
	away_dialog.dialog_text = text
	away_dialog.popup_centered.call_deferred()


## Everything the game needs to resume, as JSON-safe values.
static func capture(economy: Economy, mine: Mine, now: float) -> Dictionary:
	var shaft := mine.shaft
	return {
		"version": FORMAT_VERSION,
		"saved_at": now,
		"mine": {
			"seed": shaft.shaft_seed,
			"depth": shaft.depth,
			"damage": shaft.damage,
			"revealed": shaft.revealed,
			"ores": mine.ores.duplicate(),
		},
		"heart_share": economy.split.heart_share,
		"heart": { "stage": economy.heart.stage, "progress": economy.heart.progress },
		"furnace": { "fuel": economy.furnace.fuel, "burn_left": economy.furnace.burn_left },
		"turbine": {
			"built": economy.turbine_built,
			"fuel": economy.turbine.boiler.fuel,
			"burn_left": economy.turbine.boiler.burn_left,
			"water": economy.turbine.water,
		},
	}


## Returns why [param data] is not a usable save, or an empty String when it is.
static func validate(data: Variant) -> String:
	if not data is Dictionary:
		return "not valid JSON"
	if not data.has("version"):
		return "no format version"
	if int(data["version"]) > FORMAT_VERSION:
		return "made by a newer build (format %d)" % int(data["version"])
	for key in ["saved_at", "mine", "heart_share", "heart", "furnace", "turbine"]:
		if not data.has(key):
			return "missing \"%s\"" % key
	return ""


## Restores [param data] (already validated) into the running game.
static func apply(data: Dictionary, economy: Economy, mine: Mine) -> void:
	var shaft := mine.shaft
	shaft.shaft_seed = int(data["mine"]["seed"])
	shaft.depth = int(data["mine"]["depth"])
	shaft.damage = data["mine"]["damage"]
	shaft.revealed = data["mine"]["revealed"]
	for id in data["mine"]["ores"]:
		mine.ores[id] = int(data["mine"]["ores"][id])
	economy.split.heart_share = data["heart_share"]
	economy.heart.stage = int(data["heart"]["stage"])
	economy.heart.progress = data["heart"]["progress"]
	economy.furnace.fuel = int(data["furnace"]["fuel"])
	economy.furnace.burn_left = data["furnace"]["burn_left"]
	economy.turbine_built = data["turbine"]["built"]
	economy.turbine.boiler.fuel = int(data["turbine"]["fuel"])
	economy.turbine.boiler.burn_left = data["turbine"]["burn_left"]
	economy.turbine.water = data["turbine"]["water"]
	economy.apply_heart()
	mine.changed.emit()


## The numbers the away summary compares.
static func snapshot(economy: Economy, mine: Mine) -> Dictionary:
	return {
		"depth": mine.shaft.depth,
		"ores": mine.ores.duplicate(),
		"stage": economy.heart.stage,
		"heart": economy.heart.progress,
	}


## One message saying what changed between [param before] and [param after].
static func summary(before: Dictionary, after: Dictionary, seconds: float) -> String:
	var lines := PackedStringArray(["While you were away (%dh %02dm):" % [int(seconds) / 3600, int(seconds) % 3600 / 60]])
	lines.append("Dug %d m deeper, now at %d m" % [after["depth"] - before["depth"], after["depth"]])
	for id in after["ores"]:
		var gained: int = after["ores"][id] - before["ores"].get(id, 0)
		if gained > 0:
			lines.append("%s: %d found" % [id.capitalize(), gained])
		elif gained < 0:
			lines.append("%s: %d used" % [id.capitalize(), -gained])
	if after["stage"] > before["stage"]:
		lines.append("The Heart reached stage %d" % after["stage"])
	elif after["heart"] > before["heart"]:
		lines.append("The Heart stored %.0f power" % (after["heart"] - before["heart"]))
	if lines.size() == 2 and after["depth"] == before["depth"]:
		lines.append("Nothing ran: the furnace was out of fuel.")
	return "\n".join(lines)
