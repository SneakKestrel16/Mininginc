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

var _hardness_base: float
var _hardness_per_block: float
var _ores: Array


## [param ores] is the "ores" list from data/ores.json: entries with id, min_depth,
## max_depth and chance, checked in order.
func _init(seed_value: int, hardness_base: float, hardness_per_block: float, ores: Array) -> void:
	shaft_seed = seed_value
	_hardness_base = hardness_base
	_hardness_per_block = hardness_per_block
	_ores = ores


## Hits needed to break the block at [param at_depth]; grows with depth.
func hardness(at_depth: int) -> int:
	return ceili(_hardness_base + _hardness_per_block * at_depth)


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
	revealed = true
	damage += power
	if damage < hardness(depth):
		return ""
	var contents := block_at(depth)
	depth += 1
	damage = 0.0
	revealed = false
	return contents
