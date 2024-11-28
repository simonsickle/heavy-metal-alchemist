shader_type canvas_item;
render_mode blend_mix;

uniform float Line_Smoothness : hint_range(0.001, 0.1) = 0.05;
uniform float Line_Width : hint_range(0.01, 0.2) = 0.1;
uniform float Rotation_deg : hint_range(-90, 90) = 45.0;
uniform float Speed = 1.0;

void fragment() {
    // Sample the base texture (the icon underneath)
    vec4 base_color = texture(TEXTURE, UV);

    // Centered UV and rotation for the shimmer line
    vec2 center_uv = UV - vec2(0.5, 0.5);
    float angle = radians(Rotation_deg);
    mat2 rotation_matrix = mat2(
        vec2(cos(angle), -sin(angle)), // First column
        vec2(sin(angle), cos(angle))  // Second column
    );
    vec2 rotated_uv = rotation_matrix * center_uv;

    // Calculate the shimmer line position and width
    float shimmer_position = fract(TIME * Speed) * 2.0 - 1.0; // Moves across the UV space
    float line_dist = abs(rotated_uv.x - shimmer_position);

    // Line smoothness
    float line_alpha = smoothstep(Line_Width + Line_Smoothness, Line_Width, line_dist);

    // Combine base color with the shimmer effect
    vec3 shimmer_color = vec3(1.0); // White color for the shimmer
    vec3 final_color = mix(base_color.rgb, shimmer_color, line_alpha);

    // Set the final color and alpha
    COLOR.rgb = final_color;
    COLOR.a = base_color.a; // Maintain the original alpha
}
