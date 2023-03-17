// From Godot docs - https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_second_3d_shader.html?highlight=time#animating-with-time
shader_type spatial;

render_mode specular_toon;

uniform sampler2D noise;
uniform sampler2D normalmap;

uniform float height_scale = 0.5;

varying vec2 tex_position;

float wave(vec2 position) {
	position += texture(noise, position / 10.0).x * 2.0 - 1.0;
	vec2 wv = 1.0 - abs(sin(position));
	return pow(1.0 - pow(wv.x * wv.y, 0.7), 4.0);
}

float height(vec2 position, float time) {
	
	float d = wave((position + time) * 0.4) * 0.35;
	d += wave((position - time) * 0.3) * 0.15;
	d += wave((position + time) * 0.5) * 0.25;
	d += wave((position - time) * 0.6) * 0.25;

	return d;
}

void vertex() {
	
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME);
	VERTEX.y = k;

	
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment() {

	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
	
}