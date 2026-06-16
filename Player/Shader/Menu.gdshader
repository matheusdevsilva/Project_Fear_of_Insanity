shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur = 2.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	vec4 col = vec4(0.0);

	// mais amostras = mais suave
	col += texture(SCREEN_TEXTURE, uv + vec2(-blur, 0.0) * SCREEN_PIXEL_SIZE);
	col += texture(SCREEN_TEXTURE, uv + vec2( blur, 0.0) * SCREEN_PIXEL_SIZE);
	col += texture(SCREEN_TEXTURE, uv + vec2(0.0, -blur) * SCREEN_PIXEL_SIZE);
	col += texture(SCREEN_TEXTURE, uv + vec2(0.0,  blur) * SCREEN_PIXEL_SIZE);

	col += texture(SCREEN_TEXTURE, uv);

	col /= 5.0;

	COLOR = col;
}