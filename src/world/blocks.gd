## Block types of the voxel moon (brief: Milestone 3D item 15). Ore blocks carry the same
## ids as data/ores.json and the inventory, so a broken block's name is what it yields.
class_name Blocks
extends RefCounted

const AIR := 0
const BEDROCK := 1
const CRUST := 2
const ROCK := 3

## Index is the block id. Ores follow the fixed types, in this order.
const NAMES: Array[String] = ["air", "bedrock", "crust", "rock", "coal", "ice", "copper", "uranium"]

const COLORS: Array[Color] = [
	Color(0, 0, 0, 0),
	Color(0.08, 0.08, 0.1),
	Color(0.66, 0.72, 0.8),
	Color(0.36, 0.36, 0.42),
	Color(0.12, 0.12, 0.12),
	Color(0.55, 0.85, 1.0),
	Color(0.85, 0.45, 0.2),
	Color(0.35, 0.95, 0.35),
]


## The block id for [param block_name], or -1 when there is no such block.
static func id_of(block_name: String) -> int:
	return NAMES.find(block_name)
