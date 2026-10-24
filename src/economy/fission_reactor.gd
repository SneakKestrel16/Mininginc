## A fission reactor: burns hand-fed uranium for far more power than the turbine, and
## builds heat while it runs (brief: Milestone 2 items 9–11). Ice cools it; at the heat
## limit it scrams and stays off until it cools to the restart level. Every uranium burned
## leaves waste. Pure logic with no scene dependency.
class_name FissionReactor
extends RefCounted

## Burns the uranium; its power_per_second is the reactor's output.
var core: Furnace
## Heat built up so far, from 0 to [member heat_limit].
var heat: float = 0.0
## Heat at which the reactor scrams.
var heat_limit: float
## Heat a scrammed reactor must cool to before it runs again.
var restart_heat: float
## Heat added per second while running at full power.
var heat_per_second: float
## Heat lost per second on its own, running or not.
var cooling_per_second: float
## Heat one piece of ice removes.
var heat_per_ice: float
## True from the moment heat reaches the limit until it falls to [member restart_heat].
var scrammed: bool = false
## Waste piled up, one [member waste_per_uranium] per uranium burned.
var waste: float = 0.0
## Waste one uranium leaves once fully burned.
var waste_per_uranium: float


func _init(fuel_capacity: int, seconds_per_uranium: float, power: float, heat_rate: float,
		limit: float, restart: float, cooling: float, ice_cooling: float, waste_rate: float) -> void:
	core = Furnace.new(fuel_capacity, seconds_per_uranium, power)
	heat_per_second = heat_rate
	heat_limit = limit
	restart_heat = restart
	cooling_per_second = cooling
	heat_per_ice = ice_cooling
	waste_per_uranium = waste_rate


## Pieces of ice it takes to remove all the heat, the last one only partly used.
func ice_space() -> int:
	return ceili(heat / heat_per_ice)


## Melts up to [param available] ice against the heat, as much as it takes. Returns how many went in.
func cool(available: int) -> int:
	var used := mini(ice_space(), available)
	heat = maxf(heat - used * heat_per_ice, 0.0)
	_check_restart()
	return used


## Runs for [param seconds] and returns the average power produced over them.
## The tick is split where heat reaches the limit, so a long offline step scrams at the
## same moment live play would.
func tick(seconds: float) -> float:
	var energy := 0.0
	var idle := seconds
	if not scrammed and core.is_burning():
		var net := heat_per_second - cooling_per_second
		var run := seconds if net <= 0.0 else minf(seconds, (heat_limit - heat) / net)
		if run > 0.0:  # Furnace.tick divides by its seconds
			energy = core.tick(run) * run
		var burned := energy / core.power_per_second
		heat = maxf(heat + heat_per_second * burned - cooling_per_second * run, 0.0)
		waste += burned / core.burn_seconds * waste_per_uranium
		idle -= run
		if heat >= heat_limit - 0.0001:
			heat = heat_limit
			scrammed = true
	heat = maxf(heat - cooling_per_second * idle, 0.0)
	_check_restart()
	return energy / seconds


## True while burning uranium: not scrammed and with uranium left.
func is_running() -> bool:
	return not scrammed and core.is_burning()


func _check_restart() -> void:
	if scrammed and heat <= restart_heat:
		scrammed = false
