shader_type canvas_item;

// Godot 4 requires us to grab the screen texture like this
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Expose parameters to the Inspector so you can tweak them easily!
uniform float scanline_count : hint_range(0.0, 1080.0) = 250.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float curvature : hint_range(1.0, 10.0) = 3.0;
uniform float vignette_multiplier = 2.5;

void fragment() {
    // 1. Center the UV coordinates for the curvature math
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    
    // 2. Apply the fish-eye curvature effect
    vec2 offset = centered_uv.yx / curvature;
    vec2 curved_uv = centered_uv + centered_uv * offset * offset;
    
    // 3. Return to normal UV space (0.0 to 1.0)
    curved_uv = curved_uv * 0.5 + 0.5;
    
    // 4. If the curve pushes the texture off-screen, draw black borders
    if (curved_uv.x < 0.0 || curved_uv.x > 1.0 || curved_uv.y < 0.0 || curved_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // 5. Get the actual game pixel behind the ColorRect
        vec4 screen_color = texture(screen_texture, curved_uv);
        
        // 6. Create the horizontal Scanlines
        float scanline = sin(curved_uv.y * scanline_count * PI * 2.0);
        // Soften the scanline so it isn't pure black
        scanline = (scanline * 0.5 + 0.5) * scanline_intensity + (1.0 - scanline_intensity);
        
        // 7. Create the Vignette (dark corners)
        float vignette = curved_uv.x * curved_uv.y * (1.0 - curved_uv.x) * (1.0 - curved_uv.y);
        vignette = clamp(pow(vignette * 15.0, vignette_multiplier), 0.0, 1.0);
        
        // 8. Output the final modified color
        COLOR = screen_color * scanline * vignette;
    }
}