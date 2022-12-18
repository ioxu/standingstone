shader_type canvas_item;
// this shader is applied to ViewportDisplay/ViewportDisplayTextureRect

uniform float contrast = 1.0;
uniform float exposure = 0.0;
uniform float saturation = 1.0;


// bayer / quantize filter
// https://www.shadertoy.com/view/4ddGWr
uniform bool apply_bayer_filter = false;
uniform float bayer_scale = 1.0;
uniform float bayer_matrix_dim_size = 4.0;
uniform sampler2D bayer_texture;
uniform float bayerQuantizeRGBSize = 16.;// number of values possible for each R, G, B.


float quantize(float inp, float period)
{
    return floor((inp+period/2.)/period)*period;
}


void fragment() {
	// bayer
	if (apply_bayer_filter) {
    	// space between values of the dest palette
    	vec3 quantizationPeriod = vec3(1./(bayerQuantizeRGBSize-1.));

		// dither
		vec2 bayer_coords = fract( (UV / SCREEN_PIXEL_SIZE) * (1.0/bayer_matrix_dim_size) * (1./bayer_scale) ) ;
		float dither = texture( bayer_texture, bayer_coords ).r * 0.98 + 0.01;

		// get screen and colour-correct
		vec2 uvPixellated = floor(FRAGCOORD.xy / bayer_scale)*bayer_scale;
		uvPixellated = uvPixellated / (1.0/SCREEN_PIXEL_SIZE);
		uvPixellated.y = 1.0-uvPixellated.y;
	    vec3 c = texture(TEXTURE, uvPixellated ).rgb ;

//		vec3 cc = c;
//		// contrast
//		cc.rgb = 0.5 + contrast * (cc.rgb - 0.5);
//
//		// exposure
//		cc.rgb = (1.0 + exposure) * cc.rgb;
//
//		// saturation
//		cc.rgb = mix(vec3(dot(vec3(1.0), cc.rgb)*0.333333), cc.rgb, saturation);
//
//		// greyscale: https://www.shadertoy.com/view/4tlyDN
//		float grey = dot(cc, vec3(0.2126, 0.7152, 0.0722)) ;

		c += (dither - 0.5) * (quantizationPeriod);
	    // quantize color to palette
		c = vec3(
			quantize(c.r, quantizationPeriod.r),
			quantize(c.g, quantizationPeriod.g),
			quantize(c.b, quantizationPeriod.b)
				);
		COLOR = vec4( c, 1.0);
	}
	else {
		COLOR = texture(TEXTURE, UV);
	}
}