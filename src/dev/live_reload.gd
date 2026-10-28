## Dev-only live reload: while the game runs from source (a debug build), scripts under
## res://src that change on disk are reloaded in place, keeping each object's state, so a
## fix shows up without restarting. Off in exported release builds. Scene and data/*.json
## changes still need a restart: those are read once when nodes are made, and so do changes
## to this script (reloading itself from inside its own _process crashes the engine).
class_name LiveReload
extends Node

## Seconds between checks of the scripts' modified times.
const CHECK_SECONDS := 1.0
const ROOT := "res://src"

var _stamps: Dictionary = {}
var _since := 0.0


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	for path in _scripts(ROOT):
		_stamps[path] = FileAccess.get_modified_time(path)


func _process(delta: float) -> void:
	_since += delta
	if _since < CHECK_SECONDS:
		return
	_since = 0.0
	for path in _scripts(ROOT):
		var stamp := FileAccess.get_modified_time(path)
		if _stamps.get(path, stamp) != stamp:
			_reload(path)
		_stamps[path] = stamp


func _reload(path: String) -> void:
	if path == get_script().resource_path:
		return
	var script := load(path) as GDScript
	if script == null:
		return
	var old := script.source_code
	script.source_code = FileAccess.get_file_as_string(path)
	var result := script.reload(true)  # keep_state: running objects keep their member values
	if result == OK:
		print("[live reload] %s" % path)
	else:
		# A failed reload leaves the script unusable; put the old source back so the running
		# objects keep working until the file compiles.
		script.source_code = old
		script.reload(true)
		push_error("[live reload] %s did not compile (error %d); the old code keeps running" % [path, result])


func _scripts(dir: String) -> PackedStringArray:
	var found := PackedStringArray()
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".gd"):
			found.append(dir.path_join(file))
	for sub in DirAccess.get_directories_at(dir):
		found.append_array(_scripts(dir.path_join(sub)))
	return found
