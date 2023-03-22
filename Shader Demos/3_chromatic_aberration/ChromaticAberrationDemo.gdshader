// from Heartbeast - https://www.youtube.com/watch?v=-PJOHAsBcoI&t=168s

shader_type canvas_item;

uniform bool active = true;
uniform float amount = 1.0;
uniform sampler2D offset_tex : hint_default_white;

// editor color picker
//uniform vec4 color : hint_color = vec4(1.0,1.0,1.0,1.0);

void fragment() {
	// the source's color per uv on texture
	vec4 texture_color = texture(TEXTURE, UV);
//	vec4 color = vec4(1.0,1.0,1.0,1.0);
	vec4 color = texture_color;
	
	if(active)
	{
		// mult amount by offset tex, so darker areas have less offset
		float adjusted_amt = amount * texture(offset_tex, UV).r / 100.0;
		color.r = texture(TEXTURE, vec2(UV.x + adjusted_amt, UV.y)).r;
		color.g = texture(TEXTURE, UV).g;
		color.b = texture(TEXTURE, vec2(UV.x - adjusted_amt, UV.y)).b;
	}
	COLOR = color;
}