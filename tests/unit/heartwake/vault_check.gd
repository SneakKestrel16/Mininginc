## Self-check for vaults (brief: Milestone 10 item 45) until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/vault_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var world := _world(7)
	var twin := _world(7)
	var other := _world(8)
	var third := _world(1234)
	var bare := _world(7)
	var loaded := _world(7)
	await process_frame  # _ready runs on the next frame
	for stratum in bare.strata:
		stratum.erase("vaults")
	bare._seed_noise()

	# The seed alone places them: the same seed, the same vaults; every one the data asks for.
	failures += _check(_layout(world) == _layout(twin) and _layout(world) != _layout(other), "the same seed gives the same vaults; another does not")
	for w in [world, other, third]:
		var per := {}
		for vault in w.vaults:
			per[vault["stratum"]] = per.get(vault["stratum"], 0) + 1
		var want := {}
		for s in w.strata.size():
			if w.strata[s].has("vaults"):
				want[s] = int(w.strata[s]["vaults"]["count"])
		failures += _check(per == want, "seed %d places every vault the strata ask for (%s)" % [w.world_seed, per])
	failures += _check(bare.vaults.is_empty() and world._vault_top < -140.0, "without vault data there are none; with it none reach above 140 m")

	# Each lies inside its stratum, clear of the walls and of every other vault.
	var placed := true
	for i in world.vaults.size():
		var vault: Dictionary = world.vaults[i]
		var c: Vector3 = vault["center"]
		var outer: float = vault["radius"] + VoxelWorld.VAULT_LUMPS + vault["shell"]
		var top: float = world.strata[vault["stratum"]]["from_depth"]
		var bottom: float = world.strata[vault["stratum"] + 1]["from_depth"] if vault["stratum"] + 1 < world.strata.size() else world.max_depth
		var half := outer / VoxelWorld.VAULT_SQUASH + VoxelWorld.VAULT_CLEAR
		placed = placed and -c.y - half >= top and -c.y + half <= bottom
		placed = placed and minf(c.x, c.z) >= outer + VoxelWorld.VAULT_CLEAR and maxf(c.x, c.z) <= world.world_size - outer - VoxelWorld.VAULT_CLEAR
		for j in range(i + 1, world.vaults.size()):
			var b: Dictionary = world.vaults[j]
			placed = placed and c.distance_to(b["center"]) >= outer + b["radius"] + VoxelWorld.VAULT_LUMPS + b["shell"] + 2.0 * VoxelWorld.VAULT_CLEAR
	failures += _check(placed, "every vault lies inside its stratum, clear of the walls and the others")

	# Hollow and sealed: open air at the middle, and the air there reaches nothing else.
	var sealed := true
	var hollow := true
	for vault in world.vaults:
		var c: Vector3 = vault["center"]
		hollow = hollow and not world.is_solid(Vector3i(c.round())) and not world.is_solid(Vector3i((c + Vector3(0.5 * vault["radius"], 0, 0)).round()))
		var reach: float = vault["radius"] + VoxelWorld.VAULT_LUMPS + 1.0
		var seen := { Vector3i(c.round()): true }
		var stack: Array[Vector3i] = [Vector3i(c.round())]
		while not stack.is_empty() and seen.size() < 20000:
			var pos: Vector3i = stack.pop_back()
			var off := Vector3(pos) - c
			if absf(off.x) > reach or absf(off.z) > reach or absf(off.y) > reach / VoxelWorld.VAULT_SQUASH + 1.0:
				sealed = false
				break
			for side in VoxelWorld.SIDES:
				var next: Vector3i = pos + side
				if not seen.has(next) and not world.is_solid(next):
					seen[next] = true
					stack.append(next)
		sealed = sealed and stack.is_empty()
	failures += _check(hollow, "every vault is open air at its middle")
	failures += _check(sealed, "every vault's air is sealed in by rock")

	# Outside the vaults the ground is what it would be without them.
	var same := true
	var checked := 0
	for i in 20000:
		var pos := Vector3i(1 + (i * 37) % 126, -(i * 13) % 400, 1 + (i * 91) % 126)
		if world.vaults.any(func(v: Dictionary) -> bool: return _inside(v, pos)):
			continue
		checked += 1
		same = same and world.generated_density(pos) == bare.generated_density(pos) and world.material_at(pos) == bare.material_at(pos)
	failures += _check(same and checked > 19000, "outside the vaults the ground is unchanged (%d samples)" % checked)

	# Walls of the stratum's own ore, about as much as its cover asks for.
	var walls := true
	var counts := []
	for vault in world.vaults:
		var shell := 0
		var ore := 0
		var c: Vector3 = vault["center"]
		var outer: float = vault["radius"] + VoxelWorld.VAULT_LUMPS + vault["shell"] + 1.0
		for x in range(floori(c.x - outer), ceili(c.x + outer) + 1):
			for y in range(floori(c.y - outer / VoxelWorld.VAULT_SQUASH), ceili(c.y + outer / VoxelWorld.VAULT_SQUASH) + 1):
				for z in range(floori(c.z - outer), ceili(c.z + outer) + 1):
					var pos := Vector3i(x, y, z)
					var cavity := world._cavity(vault, Vector3(pos))
					if cavity > 0.0 and cavity <= vault["shell"] and world.is_solid(pos):
						shell += 1
						ore += int(world.material_at(pos) == vault["ore"])
		var cover: float = world.strata[vault["stratum"]]["vaults"]["cover"]
		walls = walls and ore >= 100 and ore <= 500 and absf(ore / float(shell) - cover) <= 0.1
		counts.append(ore)
	failures += _check(walls, "every vault is walled with 100-500 of its stratum's ore, near its cover (%s)" % [counts])

	# Its chunks are open, so the hollow is drawn; a reseed closes the old seed's.
	var vault0: Dictionary = world.vaults[0]
	var key := world.chunk_of(Vector3i(vault0["center"].round()))
	failures += _check(world._open_chunks.has(key), "a vault's chunks are open to be drawn")
	world.update_around(vault0["center"])
	var chunk: Node3D = world.chunk_node(key)
	failures += _check(chunk != null and chunk.get_child_count() == 2, "and its chunk meshes with collision")
	var old_chunks: Array[Vector3i] = twin._vault_chunks.duplicate()
	twin.world_seed = 8
	failures += _check(old_chunks.all(func(k: Vector3i) -> bool: return not twin._open_chunks.has(k) or twin._vault_chunks.has(k)),
			"a reseed closes the old seed's vault chunks")

	# A light glows in a vault near the player, in its ore's colour, and goes when the player does.
	failures += _check(world._vault_lights.has(0) and world._vault_lights[0].light_color == vault0["glow"]
			and not world._vault_lights[0].shadow_enabled, "a vault near the player has an unshadowed light in its colour")
	world.update_around(Vector3(vault0["center"].x, 1, vault0["center"].z))
	failures += _check(world.vault_light_count() == 0, "back at the surface no vault light is left")

	# Breaking in: the first scoop to reach the hollow tells, once; one 3 m clear does not.
	var heard := []
	world.vault_opened.connect(func(i: int, ore: String) -> void: heard.append([i, ore]))
	var clear := _toward(world, vault0, vault0["shell"] + 3.0)
	world.carve(clear, world.bite_radius)
	failures += _check(heard.is_empty(), "a scoop 3 m clear of the shell opens nothing")
	var edge := _toward(world, vault0, 0.8)
	world.carve(edge, world.bite_radius)
	world.carve(edge + Vector3(0, 0.5, 0), world.bite_radius)
	failures += _check(heard == [[0, Blocks.NAMES[vault0["ore"]]]], "breaking in tells which vault and its ore, once (%s)" % [heard])
	# From above and below too, where the squash puts the hollow nearer than a centre's distance says.
	for approach in [[1, -0.1], [2, 0.1], [3, -0.1], [4, 0.1]]:
		var late := _banner_at_breach(world, approach[0], approach[1])
		failures += _check(late == "", "digging %s into vault %d tells with the scoop that breaks in (%s)"
				% ["down" if approach[1] < 0.0 else "up", approach[0], late])

	# Auto-drills pay for rock, not for a vault's air; elsewhere exactly what they always did.
	failures += _check(_drill_pays_for_rock(third, third.vaults[3]), "a drill through a vault pays only for its rock")
	failures += _check(_drill_pays_for_rock(third, {}), "a drill through plain rock pays what it always did")
	# The widest scoop's roof-breaking bite also reaches into the hollow; that air is still free.
	third.bite_bonus = 1.25
	var wide := [4, 5, 6, 7, 8, 9].filter(func(i: int) -> bool: return not _drill_pays_for_rock(third, third.vaults[i]))
	third.bite_bonus = 0.0
	failures += _check(wide.is_empty(), "with the widest scoop a drill through a vault pays only for its rock (paid air at %s)" % [wide])

	# A save from before vaults: its carved edges, solid just outside each scoop, cannot fill a
	# vault the seed now hollows out. An edit only ever carves.
	var column: Vector3 = vault0["center"]
	for y in range(int(column.y) + 10, int(column.y) - 10, -1):
		bare.carve(Vector3(column.x, y, column.z), bare.bite_radius)
	loaded.load_edits(bare.edits_flat())
	var ghosts := 0
	for pos in loaded.edits:
		ghosts += int(loaded._cavity(vault0, Vector3(pos)) <= 0.0 and loaded.is_solid(pos))
	failures += _check(ghosts == 0 and loaded.edits.size() > 100, "an old save's edits leave no rock in a vault's hollow (%d)" % ghosts)

	# The HUD's hint: distance and height, rounded, never which way across.
	var hud: GDScript = load("res://src/ui/hud.gd")
	failures += _check(hud.vault_line(Vector3(10, -150, 10), Vector3(38, -163, 20)) == "Vault: about 30 m away, 15 m down"
			and hud.vault_line(Vector3(10, -150, 10), Vector3(35, -151, 10)) == "Vault: about 25 m away, level with you",
			"the vault hint names distance and depth only")

	print("vault_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


# Bores a drill down the column through [param vault]'s middle (or a vault-free column when
# empty) with exactly the hits its solid cells cost, and says whether that took it through.
func _drill_pays_for_rock(world: VoxelWorld, vault: Dictionary) -> bool:
	var column := Vector2i(10, 10)
	var top := -160
	# A column no vault comes near, for the plain-rock case.
	while world.vaults.any(func(v: Dictionary) -> bool: return absf(v["center"].x - column.x) < 12.0 and absf(v["center"].z - column.y) < 12.0):
		column += Vector2i(7, 3)
	if not vault.is_empty():
		column = Vector2i(floori(vault["center"].x), floori(vault["center"].z))
		top = floori(vault["center"].y + vault["radius"] / VoxelWorld.VAULT_SQUASH + 4.0)
	var bottom := top - 20
	var cost := 0.0
	var air := 0
	for y in range(top, bottom, -1):
		var pos := Vector3i(column.x, y, column.y)
		if world.generated_density(pos) > 0.0:
			cost += world.hardness_at(pos)
		else:
			air += 1
	var drill := AutoDrill.new()
	drill.setup(world, null, Vector3i(column.x, top, column.y))
	drill.dig(cost)
	var through: bool = drill.depth_y == bottom and world.damage.get(Vector3i(column.x, bottom, column.y), 0.0) < 0.01
	drill.free()
	return through and (air > 3) == not vault.is_empty()


# Scoops up or down the vertical through vault [param index]'s middle from outside its shell,
# [param step] metres at a time (negative: down from above). Empty when vault_opened came with
# the first scoop whose air joins the hollow's, else what happened instead.
func _banner_at_breach(world: VoxelWorld, index: int, step: float) -> String:
	var vault: Dictionary = world.vaults[index]
	var heard := [0]  # an array: a lambda captures locals by value
	var on_open := func(i: int, _ore: String) -> void:
		if i == index:
			heard[0] += 1
	world.vault_opened.connect(on_open)
	var outside: float = (vault["radius"] + VoxelWorld.VAULT_LUMPS + vault["shell"] + world.bite_radius) / VoxelWorld.VAULT_SQUASH + 2.0
	var at: Vector3 = vault["center"] - Vector3(0, signf(step) * outside, 0)
	var result := "never broke in"
	for n in 300:
		world.carve(at, world.bite_radius)
		var breached := _reaches_hollow(world, vault, Vector3i(at.floor()))
		if heard[0] > 0 or breached:
			result = "" if heard[0] == 1 and breached else "%.1f m from the middle: banner %d, broken in %s" % [
					at.y - vault["center"].y, heard[0], breached]
			break
		at.y += step
	world.vault_opened.disconnect(on_open)
	return result


# True when open air leads from [param from] to a sample of [param vault]'s hollow.
func _reaches_hollow(world: VoxelWorld, vault: Dictionary, from: Vector3i) -> bool:
	var seen := { from: true }
	var stack: Array[Vector3i] = [from]
	while not stack.is_empty() and seen.size() < 20000:
		var pos: Vector3i = stack.pop_back()
		if world._cavity(vault, Vector3(pos)) <= 0.0:
			return true
		for side in VoxelWorld.SIDES:
			var next: Vector3i = pos + side
			if not seen.has(next) and not world.is_solid(next) and Vector3(next).distance_to(vault["center"]) < 20.0:
				seen[next] = true
				stack.append(next)
	return false


# A point straight out from [param vault]'s middle, [param out] squashed metres past its hollow.
func _toward(world: VoxelWorld, vault: Dictionary, out: float) -> Vector3:
	var at: Vector3 = vault["center"]
	while world._cavity(vault, at) < out:
		at.x += 0.05
	return at


func _inside(vault: Dictionary, pos: Vector3i) -> bool:
	var outer: float = vault["radius"] + VoxelWorld.VAULT_LUMPS + vault["shell"] + 1.0
	var off: Vector3 = Vector3(pos) - vault["center"]
	return absf(off.x) <= outer and absf(off.z) <= outer and absf(off.y) <= outer / VoxelWorld.VAULT_SQUASH + 1.0


func _layout(world: VoxelWorld) -> Array:
	return world.vaults.map(func(v: Dictionary) -> Array: return [v["center"], v["radius"], v["ore"]])


func _world(seed_value: int) -> VoxelWorld:
	var world := VoxelWorld.new()
	world.world_seed = seed_value
	root.add_child(world)
	return world


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
