shader_type canvas_item;
render_mode unshaded;
uniform vec2 view_size = vec2(960.0,540.0);
uniform vec2 player_screen = vec2(480.0,270.0);
uniform float radius = 440.0;
uniform float darkness = 0.65;
void fragment() {
	float distance_to_player = distance(UV * view_size, player_screen);
	float fog = smoothstep(radius, radius + 90.0, distance_to_player);
	COLOR = vec4(0.015,0.025,0.055,fog * darkness);
}
