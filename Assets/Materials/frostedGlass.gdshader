shader_type spatial;
render_mode shadows_disabled;


uniform float distortion_size = 0.4;
uniform sampler2D glass;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : source_color, hint_depth_texture;

void fragment() {
	vec2 d = texture(glass, UV).xy - vec2(0.5);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + d * sqrt(texture(depth_texture, UV).r) * distortion_size).rgb * 0.9 + vec3(0.1);
	ALPHA = 0.99;
}