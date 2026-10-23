## A furnace that burns hand-fed coal into power (brief: MVP feature 2).
## Pure logic with no scene dependency. It holds whole pieces of coal and burns one at a
## time; when the last piece burns out it stops, which is the brief's stall.
class_name Furnace
extends RefCounted

## Most coal the furnace holds, counting the piece burning.
var capacity: int
## Seconds one piece of coal burns.
var burn_seconds: float
## Power produced per second while burning.
var power_per_second: float

## Unburned pieces waiting in the furnace.
var fuel: int = 0
## Seconds left on the piece burning now; 0 when nothing burns.
var burn_left: float = 0.0


func _init(fuel_capacity: int, seconds_per_coal: float, power: float) -> void:
	capacity = fuel_capacity
	burn_seconds = seconds_per_coal
	power_per_second = power


## Pieces of coal that still fit.
func space() -> int:
	return maxi(capacity - fuel - (1 if burn_left > 0.0 else 0), 0)


## Loads up to [param available] coal, as much as fits. Returns how many went in.
func feed(available: int) -> int:
	var loaded := mini(space(), available)
	fuel += loaded
	return loaded


## Burns for [param seconds] and returns the average power produced over them.
## Starts the next piece as soon as one burns out, so output only stops when all fuel is gone.
func tick(seconds: float) -> float:
	var remaining := seconds
	var burned := 0.0
	while remaining > 0.0:
		if burn_left <= 0.0:
			if fuel == 0:
				break
			fuel -= 1
			burn_left = burn_seconds
		var used := minf(burn_left, remaining)
		burn_left -= used
		remaining -= used
		burned += used
	return power_per_second * burned / seconds


## Fuel left, in pieces of coal, counting the part of the piece still burning.
func fuel_level() -> float:
	return fuel + burn_left / burn_seconds


## True while there is anything left to burn.
func is_burning() -> bool:
	return burn_left > 0.0 or fuel > 0
