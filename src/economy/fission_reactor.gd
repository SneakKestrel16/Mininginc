## A fission reactor: burns hand-fed uranium for far more power than the turbine, and
## builds heat while it runs (brief: Milestone 2 item 9). Pure logic with no scene dependency.
class_name FissionReactor
extends RefCounted

## Burns the uranium; its power_per_second is the reactor's output.
var core: Furnace
## Heat built up so far, from 0 to [member heat_limit].
var heat: float = 0.0
## Most heat the reactor holds.
var heat_limit: float
## Heat added per second while running at full power.
var heat_per_second: float


func _init(fuel_capacity: int, seconds_per_uranium: float, power: float, heat_rate: float,
		limit: float) -> void:
	core = Furnace.new(fuel_capacity, seconds_per_uranium, power)
	heat_per_second = heat_rate
	heat_limit = limit


## Runs for [param seconds] and returns the average power produced over them.
## Heat rises with the time spent burning; it stops when the uranium runs out.
func tick(seconds: float) -> float:
	var power := core.tick(seconds)
	var burned := seconds * power / core.power_per_second
	heat = minf(heat + heat_per_second * burned, heat_limit)
	return power


## True while there is uranium left to burn.
func is_running() -> bool:
	return core.is_burning()
