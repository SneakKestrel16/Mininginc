## Splits generated power between the drills and the Heart (brief: Core loop step 3).
## Pure logic with no scene dependency, so it can be checked headless.
class_name PowerSplit
extends RefCounted

## Fraction of power sent to the Heart: 0.0 is all drills, 1.0 is all Heart.
var heart_share: float = 0.5:
	set(value):
		heart_share = clampf(value, 0.0, 1.0)

## Power stored in the Heart toward [member heart_threshold].
var heart_progress: float = 0.0

## Power the Heart needs to reach its next stage. Story 005 advances stages.
var heart_threshold: float

## Drill share of the last tick, in power per second. Story 004 spends it.
var drill_power: float = 0.0

## Heart share of the last tick, in power per second.
var heart_power: float = 0.0


func _init(threshold: float, share: float = 0.5) -> void:
	heart_threshold = threshold
	heart_share = share


## Splits [param power_per_second] for [param seconds] of play.
## The two shares always add up to [param power_per_second].
func tick(power_per_second: float, seconds: float) -> void:
	heart_power = power_per_second * heart_share
	drill_power = power_per_second - heart_power
	heart_progress = minf(heart_progress + heart_power * seconds, heart_threshold)


## True once the Heart holds enough power for its next stage.
func is_heart_full() -> bool:
	return heart_progress >= heart_threshold
