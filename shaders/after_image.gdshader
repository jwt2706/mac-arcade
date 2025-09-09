shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 0.5;
uniform vec3 tint : source_color = vec3(0.6, 0.6, 0.6); // grey tint

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    // apply tint and transparency
    COLOR = vec4(tex.rgb * tint, tex.a * alpha);
}
