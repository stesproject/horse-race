shader_type canvas_item;

uniform sampler2D replacement_texture;
uniform float threshold : hint_range(0, 1) = 0.05;
uniform vec2 tiling = vec2(1.0); // Number of tiles in X/Y directions

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    if (all(lessThan(original_color.rgb, vec3(threshold)))) {
        // Create tiled UV coordinates using fract to repeat the pattern
        vec2 tiled_uv = fract(UV * tiling);
        vec4 replacement_color = texture(replacement_texture, tiled_uv);

        COLOR = vec4(replacement_color.rgb, original_color.a);
    } else {
        COLOR = original_color;
    }
}