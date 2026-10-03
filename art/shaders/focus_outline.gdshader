shader_type spatial;
render_mode unshaded, cull_front;
void vertex() { VERTEX += NORMAL * 0.018; }
void fragment() { ALBEDO = vec3(1.0, 0.8, 0.35); }
