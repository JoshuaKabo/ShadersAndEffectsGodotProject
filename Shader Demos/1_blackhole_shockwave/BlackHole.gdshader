// From PlayWithFurcifer https://www.youtube.com/watch?v=13V_5xpZgt4

shader_type canvas_item;

uniform sampler2D curve;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float strength : hint_range(-1, 1) = 0.5;

// using a backbuffer copy node following a screen tex shader node refreshes the screen copy buffer
	// backbuffer copies should be in viewport mode, so they copy the whole viewport

void fragment() {
	// from UV to center of tex
	vec2 vecToCenter = vec2(0.5, 0.5) - UV;
	// warp by multiplying in distance
	float distToCenter = length(vecToCenter);
	
	// Could move the curve point outwards for move of a shockwave
	float curveVal = texture(curve, vec2(distToCenter)).r;
	vec2 diff = normalize(vecToCenter) * strength * curveVal;
	
	// read in screen as a texture, then distort it (offset and warp)
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - diff);
}
