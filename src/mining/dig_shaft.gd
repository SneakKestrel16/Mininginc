## A single shaft dug straight down, one block at a time (brief: MVP feature 1).
## Pure logic with no scene dependency. Every block's contents follow from the seed and
## its depth alone, so a save only needs the seed, the depth and the damage.
class_name DigShaft
extends RefCounted

## Contents of a block that holds no ore.
const ROCK := "rock"

## Seed that decides what every block holds.
var shaft_seed: int
## Depth of the block being dug; blocks above it are already dug out.
var depth: int = 0
## Hits landed on the current block.
var damage: float = 0.0
## True once the current block has been hit, so its contents show.
var revealed: bool = false
## First depth still frozen solid. Frozen rock can be dug, but takes
## [member frozen_multiplier] times the hits; the Heart's Breath stage moves this down.
## Never impassable: a hard floor let coal run out and soft-locked the game.
var frozen_from: int
## How many times harder frozen rock is.
var frozen_multiplier: float

var _hardness_base: float
var _hardness_per_block: float
var _ores: Array


## [param ores] is the "ores" list from data/ores.json: entries with id, min_depth,
## max_depth and chance, checked in order.
func _init(seed_value: int, hardness_base: float, hardness_per_block: float, ores: Array,
		frozen_depth: int = 1 << 62, frozen_hardness: float = 1.0) -> void:
	shaft_seed = seed_value
	frozen_from = frozen_depth
	frozen_multiplier = frozen_hardness
	_hardness_base = hardness_base
	_hardness_per_block = hardness_per_block
	_ores = ores


## Hits needed to break the block at [param at_depth]; grows with depth, and frozen rock
## takes [member frozen_multiplier] times as many.
func hardness(at_depth: int) -> int:
	var hits := _hardness_base + _hardness_per_block * at_depth
	return ceili(hits * frozen_multiplier if at_depth >= frozen_from else hits)


## What the block at [param at_depth] holds: an ore id, or [constant ROCK].
func block_at(at_depth: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = shaft_seed * 1_000_003 + at_depth
	for ore in _ores:
		if at_depth >= ore["min_depth"] and at_depth <= ore["max_depth"] and rng.randf() < ore["chance"]:
			return ore["id"]
	return ROCK


## Lands [param power] hits on the current block. Returns what it held when this
## breaks it, else an empty String. Breaking moves the shaft one block down.
func hit(power: float = 1.0) -> String:
	var broken := dig(power)
	return broken[0] if broken else ""


## Lands [param hits] on the shaft, carrying hits left over from a broken block into the
## one below. Returns the contents of every block broken, top first. Drills dig this way.
func dig(hits: float) -> Array[String]:
	var broken: Array[String] = []
	if hits <= 0.0:
		return broken
	revealed = true
	damage += hits
	while damage >= hardness(depth):
		damage -= hardness(depth)
		broken.append(block_at(depth))
		depth += 1
		revealed = damage > 0.0
	return broken


## True when the current block is frozen, so it takes extra hits.
func is_frozen() -> bool:
	return depth >= frozen_from
