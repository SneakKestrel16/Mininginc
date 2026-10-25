## Saves the game to user:// on a timer and on quit, loads it on start, and plays the
## time spent away as offline progress (brief: MVP feature 7). user:// is outside the
## launcher's folder, so updates never touch saves.
class_name SaveGame
extends Node

## Bumped when the save layout changes, so a later build can migrate older saves.
const FORMAT_VERSION := 4
const CONFIG_PATH := "res://data/save.json"

@export var economy: Economy
@export var mine: Mine
## Shows what was earned while away.
@export var away_dialog: AcceptDialog
## Saved and restored where they stand; optional, so checks can run without one.
@export var player: Player

## Where the save lives. Checks and probes point it elsewhere so they never touch a real save.
var save_path := "user://savegame.json"

var _offline_cap: float
# True once the Heart has launched: the finished run must never be saved again.
var _launched := false
var _offline_step: float


func _ready() -> void:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary or not config.has_all(["autosave_seconds", "offline_cap_seconds", "offline_step_seconds"]) \
			or config["offline_step_seconds"] <= 0.0:
		push_error("Cannot read %s; saving is off this session" % CONFIG_PATH)
		OS.alert("Cannot read %s. The game will run, but nothing will be saved." % CONFIG_PATH, "Heartwake")
		return
	economy.resonance = load_resonance()
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
	if _launched:
		return
	var temp := save_path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s (error %d)" % [temp, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(capture(economy, mine, Time.get_unix_time_from_system(), player), "\t"))
	file.close()
	DirAccess.rename_absolute(temp, save_path)


## Where Resonance is kept: beside the run save, never inside it, so a new moon keeps it.
func resonance_path() -> String:
	return save_path.get_basename() + ".resonance.json"


## Resonance earned on earlier moons; 0 when there is no file or it cannot be read.
func load_resonance() -> int:
	var data = JSON.parse_string(FileAccess.get_file_as_string(resonance_path())) 			if FileAccess.file_exists(resonance_path()) else null
	return maxi(int(data.get("resonance", 0)), 0) if data is Dictionary else 0


## Ends the run after a launch (brief: Milestone 7 item 34): banks one point of Resonance,
## deletes the run save, and starts a new moon on a fresh seed. The save goes before the
## reload, so a crash mid-reset cannot bring the finished run back.
func new_moon() -> void:
	_launched = true
	var file := FileAccess.open(resonance_path(), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s (error %d)" % [resonance_path(), FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify({ "resonance": economy.resonance + 1 }))
	file.close()
	DirAccess.remove_absolute(save_path)
	get_tree().reload_current_scene()


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
	apply(data, economy, mine, player)
	var away := clampf(Time.get_unix_time_from_system() - data["saved_at"], 0.0, _offline_cap)
	if away >= _offline_step:
		var before := snapshot(economy, mine)
		economy.advance(away, _offline_step)
		_show(summary(before, snapshot(economy, mine), away))


func _show(text: String) -> void:
	away_dialog.dialog_text = text
	away_dialog.popup_centered.call_deferred()


## Everything the game needs to resume, as JSON-safe values. The world is saved as the
## blocks changed from what its seed generates, never whole chunks.
static func capture(economy: Economy, mine: Mine, now: float, player: Player = null) -> Dictionary:
	var drills := []
	for drill in mine.drills:
		drills.append([drill.column.x, drill.top_y, drill.column.y, drill.depth_y, drill.stopped])
	var data := {
		"version": FORMAT_VERSION,
		"saved_at": now,
		"mine": { "seed": mine.shaft.shaft_seed, "ores": mine.ores.duplicate() },
		"world": { "edits": mine.world.edits_flat() if mine.world else [] },
		"drills": drills,
		"heart_share": economy.split.heart_share,
		"heart": { "stage": economy.heart.stage, "progress": economy.heart.progress },
		"upgrades": economy.upgrades.levels.duplicate(),
		"furnace": { "fuel": economy.furnace.fuel, "burn_left": economy.furnace.burn_left },
		"turbine": {
			"built": economy.turbine_built,
			"fuel": economy.turbine.boiler.fuel,
			"burn_left": economy.turbine.boiler.burn_left,
			"water": economy.turbine.water,
		},
		"reactor": {
			"built": economy.reactor_built,
			"fuel": economy.reactor.core.fuel,
			"burn_left": economy.reactor.core.burn_left,
			"heat": economy.reactor.heat,
			"scrammed": economy.reactor.scrammed,
			"waste": economy.reactor.waste,
		},
	}
	if player:
		data["player"] = {
			"position": [player.global_position.x, player.global_position.y, player.global_position.z],
			"yaw": player.rotation.y,
			"pitch": player.get_node("Head").rotation.x,
		}
	return data


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
	if int(data["version"]) >= 2 and not data.has("reactor"):
		return "missing \"reactor\""
	if int(data["version"]) >= 3 and not data.has_all(["world", "drills"]):
		return "missing the world or its drills"
	return ""


## Restores [param data] (already validated) into the running game.
static func apply(data: Dictionary, economy: Economy, mine: Mine, player: Player = null) -> void:
	mine.shaft.shaft_seed = int(data["mine"]["seed"])
	if mine.world:
		mine.world.world_seed = mine.shaft.shaft_seed
	# Formats 1 and 2 predate the 3D world: their economy and ores carry over onto a fresh
	# world, with the player at the base. Format 3's block world does not fit the smooth
	# ground of format 4: it starts fresh too, at the base, and its drills come back as copper.
	if int(data["version"]) >= 4:
		if mine.world:
			mine.world.load_edits(data["world"]["edits"])
			for drill in data["drills"]:
				mine.restore_drill(Vector3i(int(drill[0]), int(drill[1]), int(drill[2])), int(drill[3]), drill[4])
		if player and data.has("player"):
			var at: Array = data["player"]["position"]
			player.global_position = Vector3(at[0], at[1], at[2])
			player.rotation.y = data["player"]["yaw"]
			player.get_node("Head").rotation.x = data["player"]["pitch"]
	for id in data["mine"]["ores"]:
		mine.ores[id] = int(data["mine"]["ores"][id])
	if int(data["version"]) == 3:
		mine.ores["copper"] = mine.ores.get("copper", 0) + data["drills"].size() * mine.drill_cost
	economy.split.heart_share = data["heart_share"]
	economy.heart.stage = int(data["heart"]["stage"])
	economy.heart.progress = data["heart"]["progress"]
	# Optional within format 4: saves from before the shop load with nothing bought.
	economy.upgrades.load_levels(data.get("upgrades", {}))
	economy.furnace.fuel = int(data["furnace"]["fuel"])
	economy.furnace.burn_left = data["furnace"]["burn_left"]
	economy.turbine_built = data["turbine"]["built"]
	economy.turbine.boiler.fuel = int(data["turbine"]["fuel"])
	economy.turbine.boiler.burn_left = data["turbine"]["burn_left"]
	economy.turbine.water = data["turbine"]["water"]
	# Format 1 (v0.1.x) predates the reactor: it stays unbuilt.
	if data.has("reactor"):
		economy.reactor_built = data["reactor"]["built"]
		economy.reactor.core.fuel = int(data["reactor"]["fuel"])
		economy.reactor.core.burn_left = data["reactor"]["burn_left"]
		economy.reactor.heat = data["reactor"]["heat"]
		economy.reactor.scrammed = data["reactor"].get("scrammed", false)
		economy.reactor.waste = data["reactor"].get("waste", 0.0)
	economy.apply_heart()
	mine.changed.emit()


## The numbers the away summary compares.
static func snapshot(economy: Economy, mine: Mine) -> Dictionary:
	return {
		"dug": mine.world.edits.size() if mine.world else 0,
		"ores": mine.ores.duplicate(),
		"stage": economy.heart.stage,
		"heart": economy.heart.progress,
	}


## One message saying what changed between [param before] and [param after].
static func summary(before: Dictionary, after: Dictionary, seconds: float) -> String:
	var lines := PackedStringArray(["While you were away (%dh %02dm):" % [int(seconds) / 3600, int(seconds) % 3600 / 60]])
	if after["dug"] > before["dug"]:
		lines.append("Drills broke %d blocks" % (after["dug"] - before["dug"]))
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
	if lines.size() == 1:
		lines.append("Nothing ran: the furnace was out of fuel.")
	return "\n".join(lines)
