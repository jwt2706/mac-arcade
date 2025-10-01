shader_type canvas_item;

// Just a small test color and size
uniform vec4 test_color = vec4(1.0, 0.0, 0.0, 0.5); // semi-transparent red
uniform vec2 test_size = vec2(50.0, 50.0); // size of the test rectangle in pixels

void fragment() {
    vec2 uv = FRAGCOORD.xy;

    // Default: fully transparent
    COLOR = vec4(0.0, 0.0, 0.0, 0.0);

    // Draw a small rectangle in the top-left corner
    if (uv.x < test_size.x && uv.y < test_size.y) {
        COLOR = test_color;
    }
}
