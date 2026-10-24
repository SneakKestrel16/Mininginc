## The Heart: stores power and wakes one stage at a time (brief: MVP feature 5).
## Pure logic with no scene dependency. Its state is the stage index and the progress
## toward the next stage; every bonus follows from the stage index, so a save needs no more.
class_name Heart
extends RefCounted

## Stages reached so far: 0 before the first, stages.size() once the last is reached.
var stage: int = 0
## Power stored toward the next stage. Excess past a threshold carries over.
var progress: float = 0.0

## Stage entries from data/heart_stages.json: name, threshold, effect, value, line.
var stages: Array


func _init(stage_list: Array) -> void:
	stages = stage_list


## Stores [param amount] of power. Returns the indexes of the stages it reached, in order.
func add(amount: float) -> Array[int]:
	var reached: Array[int] = []
	if is_awake():
		return reached
	progress += amount
	while not is_awake() and progress >= threshold():
		progress -= threshold()
		reached.append(stage)
		stage += 1
	if is_awake():
		progress = 0.0
	return reached


## True once every stage is reached; the meter has nothing further to fill.
func is_awake() -> bool:
	return stage >= stages.size()


## Power the next stage needs, or 0 once awake.
func threshold() -> float:
	return 0.0 if is_awake() else stages[stage]["threshold"]


## The latest stage reached, or an empty Dictionary before the first.
func current() -> Dictionary:
	return stages[stage - 1] if stage > 0 else {}


## True when a reached stage has [param effect].
func has_effect(effect: String) -> bool:
	return stages.slice(0, stage).any(func(s: Dictionary) -> bool: return s["effect"] == effect)


## Sum of the values of every reached stage with [param effect]; 0 when none.
func effect_total(effect: String) -> float:
	var total := 0.0
	for s in stages.slice(0, stage):
		if s["effect"] == effect:
			total += s["value"]
	return total
