## Recall (brief: Milestone 10 item 44): holding R long enough pulls the miner back to the base,
## so a dig into the deep always has a way home. Pure logic, so a check can drive it with
## made-up time; the player does the moving.
class_name Recall
extends RefCounted

## Seconds R must be held.
var seconds: float
## Seconds R has been held toward the next recall; 0 while it is up.
var held := 0.0
# True from a recall until R is let go, so holding on does not recall again.
var _fired := false


func _init(hold_seconds: float) -> void:
	seconds = hold_seconds


## Advances [param delta] seconds with R [param down] or not. True once, on the tick the hold
## completes; letting go early starts the next hold from zero.
func tick(delta: float, down: bool) -> bool:
	if not down:
		held = 0.0
		_fired = false
		return false
	if _fired:
		return false
	held += delta
	# A hair under counts: frame times are summed in floats.
	if held < seconds - 0.0001:
		return false
	held = 0.0
	_fired = true
	return true


## True while a hold is under way.
func is_holding() -> bool:
	return held > 0.0
