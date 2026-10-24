## What a scoop the player digs looks and sounds like (brief: Milestone 6 item 31): a puff of
## dust in the colour of what it cut most of, and a short crunch. Built in code: the crunch
## is filtered noise, so no audio asset ships.
class_name DigEffects
extends Node3D

## Seconds a puff of dust lives.
const DUST_SECONDS := 0.6

var _crunch := AudioStreamPlayer3D.new()


func _ready() -> void:
	top_level = true
	_crunch.stream = _make_crunch()
	_crunch.max_polyphony = 4
	add_child(_crunch)


## Plays one scoop at [param at] that removed [param collected] (material name to samples).
func play(at: Vector3, collected: Dictionary) -> void:
	var most := ""
	for what in collected:
		if most == "" or collected[what] > collected[most]:
			most = what
	_dust(at, Blocks.COLORS[maxi(Blocks.id_of(most), 0)])
	_crunch.global_position = at
	_crunch.pitch_scale = randf_range(0.8, 1.25)
	_crunch.play()


func _dust(at: Vector3, color: Color) -> void:
	var puff := CPUParticles3D.new()
	puff.one_shot = true
	puff.explosiveness = 0.9
	puff.amount = 24
	puff.lifetime = DUST_SECONDS
	puff.mesh = BoxMesh.new()
	puff.mesh.size = Vector3.ONE * 0.12
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	puff.mesh.material = material
	puff.color = color.lightened(0.15)
	puff.direction = Vector3.UP
	puff.spread = 70.0
	puff.initial_velocity_min = 1.5
	puff.initial_velocity_max = 3.5
	puff.gravity = Vector3(0, -6, 0)
	puff.scale_amount_min = 0.5
	puff.scale_amount_max = 1.2
	add_child(puff)
	puff.global_position = at
	puff.emitting = true
	get_tree().create_timer(DUST_SECONDS + 0.2).timeout.connect(puff.queue_free)


# A 0.18 s burst of low-passed noise with a fast decay: reads as rock giving way.
static func _make_crunch() -> AudioStreamWAV:
	var rate := 22050
	var frames := int(rate * 0.18)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var smooth := 0.0
	for i in frames:
		smooth = lerpf(smooth, randf_range(-1.0, 1.0), 0.25)
		var envelope := exp(-float(i) / frames * 6.0)
		data.encode_s16(i * 2, int(clampf(smooth * envelope * 1.6, -1.0, 1.0) * 30000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav
