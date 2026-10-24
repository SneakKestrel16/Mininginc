## A steam turbine: burns coal like the furnace, but only while it also has water
## (brief: MVP feature 6). Pure logic with no scene dependency. Ice is melted into its tank.
class_name SteamTurbine
extends RefCounted

## Burns the coal; its power_per_second is the turbine's output.
var boiler: Furnace
## Water in the tank.
var water: float = 0.0
## Most water the tank holds.
var water_capacity: float
## Water used per second while running.
var water_per_second: float
## Water one piece of ice melts into.
var water_per_ice: float


func _init(fuel_capacity: int, seconds_per_coal: float, power: float, tank: float,
		water_use: float, melt: float) -> void:
	boiler = Furnace.new(fuel_capacity, seconds_per_coal, power)
	water_capacity = tank
	water_per_second = water_use
	water_per_ice = melt


## Pieces of ice that still fit in the tank once melted.
func ice_space() -> int:
	return floori((water_capacity - water) / water_per_ice)


## Melts up to [param available] ice into the tank, as much as fits. Returns how many went in.
func melt(available: int) -> int:
	var melted := mini(ice_space(), available)
	water += melted * water_per_ice
	return melted


## Runs for [param seconds] and returns the average power produced over them.
## Stops when either coal or water runs out: the brief's stall.
func tick(seconds: float) -> float:
	var steam_seconds := minf(seconds, water / water_per_second)
	if steam_seconds <= 0.0:
		return 0.0
	var energy := boiler.tick(steam_seconds) * steam_seconds
	water = maxf(water - energy / boiler.power_per_second * water_per_second, 0.0)
	return energy / seconds


## True while it has both coal and water.
func is_running() -> bool:
	return boiler.is_burning() and water > 0.0
