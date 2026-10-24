## Splits generated power between the drills and the Heart (brief: Core loop step 3).
## Pure logic with no scene dependency, so it can be checked headless.
class_name PowerSplit
extends RefCounted

## Fraction of power sent to the Heart: 0.0 is all drills, 1.0 is all Heart.
var heart_share: float = 0.5:
	set(value):
		heart_share = clampf(value, 0.0, 1.0)

## Drill share of the last tick, in power per second.
var drill_power: float = 0.0

## Heart share of the last tick, in power per second. [Heart] stores it.
var heart_power: float = 0.0


func _init(share: float = 0.5) -> void:
	heart_share = share


## Splits [param power_per_second]. The two shares always add up to it.
func tick(power_per_second: float) -> void:
	heart_power = power_per_second * heart_share
	drill_power = power_per_second - heart_power
