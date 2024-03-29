// From Godot docs - https://docs.godotengine.org/en/stable/tutorials/shaders/your_first_shader/your_second_3d_shader.html?highlight=time#animating-with-time
shader_type spatial;
// high specular reflectance
render_mode specular_toon;
// shader_modes like unshaded are full presets
// examples:
// shader_mode unshaded;
// shader_mode diffuse_toon, specular_toon;
// see the spatial shader reference in docs for more

// rim lighting is often used to emulate how light passes through fabric edges

// two key properties:
// specular reflections - bright spots bounce direct into your eye
// fresnel reflectance - more reflective at shallow angles


// cool note - without changing the normals, light will continue to 
// bounce off the plane like it's flat, no matter the shader applied shape!

// noise is provided by godot, but imported in inspector like any other tex
uniform sampler2D noise;

// straight normal to vertex = set NORMAL
// normalmap from tex to vertex = set NORMALMAP (godot handles the wrapping)
uniform sampler2D normalmap;

// uniforms are for passing data from game to shader 
// (gdscript calls set_shader_param() to interact)
uniform float height_scale = 0.5;

varying vec2 tex_position;

float wave(vec2 position) {
	// curve waves: offset position by noise texuture
	position += texture(noise, position / 10.0).x * 2.0 - 1.0;
	// wavelike func: sin waves are too round, abs gives them a ridge, 0-1 range
		// 1 sub for the peak
	vec2 wv = 1.0 - abs(sin(position));
	// sharpen peaks and ridges: mult x and y and power it to sharpen peaks
		// then ridges by subbing from 1 and raise that to power
	return pow(1.0 - pow(wv.x * wv.y, 0.7), 4.0);
}

float get_height(vec2 position, float time) {
	// offset for movement
	// vec2 offset = 0.01 * cos(position + time);
	// return texture(noise, (position / 10.0) - offset).x; //scale to 10x10 plane
	
	//layer waves at different freq and amp
	// scale pos for ea to make wider / thinner
	// mult output to make shorter / taller
	float d = wave((position + time) * 0.4) * 0.35;
	d += wave((position - time) * 0.3) * 0.15;
	d += wave((position + time) * 0.5) * 0.25;
	d += wave((position - time) * 0.6) * 0.25;

	return d;
}

// vertex is positional, for each model vertex
void vertex() {
	// height changes with cos and sin applied to x and z
	//VERTEX.y += cos(VERTEX.x * 4.0) * sin(VERTEX.z * 4.0);
	
	// this is taking x and z as a vector2 for the noise in to out
	vec2 pos = VERTEX.xz;
	float k = get_height(pos, TIME);
	VERTEX.y = k;

	
	// manual normal calculation with some math for complex looking waves
	NORMAL = normalize(vec3(k - get_height(pos + vec2(0.1, 0.0), TIME), 0.1, k - get_height(pos + vec2(0.0, 0.1), TIME)));
}

// Fragement is per pixel, sets albedo color of mesh
void fragment() {
	// approx fresnel using dot prod, goot for knowing if looking at surface
	// head on or at glancing angle
	// dot prod is scalar result, w/ 0.0 meaning perpendicular, 1.0 parallel
	// 1 - dot prod to invert, and sqrt for that fresnel drop off shape
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW)); // fresnel to mix in
	RIM = 0.2; // increase light's effect at glancing angles
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	//easily darken by lowering values
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
	
	// can also use .rgb
	// NORMALMAP = texture(normalmap, tex_position).xyz;
}



// metallic and roughness:
// low roughness = shiny plastic
// high = solid color
// metallic should be close to 0 or 1
// high = metal, low = non
// metallic balances reflection and albedo, high almost ignores albedo for 
// reflection instead. low is more a blend of sky color and albedo "