// The moon's ground (brief: Milestone 9 item 39). Vertex colour is the material's colour;
// its alpha is 1 on ore and 0 on plain ground. Plain ground gets a fine grain; ore gets
// glinting specks in its own colour (light specks on coal, which is near black).
shader_type spatial;

varying vec3 world_pos;

// Specks per metre, and the share of speck cells lit on solid ore.
uniform float fleck_scale = 9.0;
uniform float fleck_share = 0.4;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float value_noise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x),
			mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
			mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x),
			mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

void fragment() {
	vec3 base = COLOR.rgb;
	float grain = value_noise(world_pos * 5.0) * 0.6 + value_noise(world_pos * 19.0) * 0.4;
	base *= 0.8 + 0.4 * grain;
	float ore = clamp(COLOR.a, 0.0, 1.0);
	vec3 cell_pos = world_pos * fleck_scale;
	vec3 cell = floor(cell_pos);
	float lit = step(1.0 - fleck_share * ore, hash(cell));
	vec3 offset = fract(cell_pos) - 0.5 + (vec3(hash(cell + 3.1), hash(cell + 7.7), hash(cell + 1.3)) - 0.5) * 0.4;
	float spot = smoothstep(0.3, 0.12, length(offset)) * lit * step(0.5, ore);
	float brightness = dot(COLOR.rgb, vec3(0.333));
	vec3 fleck = brightness < 0.12 ? vec3(0.85, 0.85, 0.9) : min(COLOR.rgb * 1.5 + 0.1, vec3(1.0));
	ALBEDO = mix(base, fleck, spot);
	ROUGHNESS = mix(0.92, 0.2, spot);
	METALLIC = spot * 0.5;
	EMISSION = fleck * spot * 0.35;
}
