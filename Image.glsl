

// activate dither
#define DITHER

// How many colors do you want on the final image ? (per channel)
#define COLORDEPTH 0.8

#define GREYSCALEINPUT
#define GREYSCALEOUTPUT

// Scale of the pixels
#define RESOLUTIONFACTOR 3.0

// use a true triangle function (different kind of noise) 
#define TRUETRIANGLE

// using a triangular function based noise give smoother noise repartition
// (this is not really a triangle function, it produces a bit more noise)
// i added the true triangle function as an option (read the pdf to understand)
float remap_noise_tri_erp( const float v )
{
    #if ( defined TRUETRIANGLE )
    return abs(fract(v+0.5)-0.5)+.25;
	#endif
    float r2 = 0.5 * v;
    float f1 = sqrt( r2 );
    float f2 = 1.0 - sqrt( r2 - 0.25 );    
    return (v < 0.5) ? f1 : f2;
}


vec3 ValveScreenSpaceDither(vec2 vScreenPos, float colorDepth)
{
    // creating the dither pattern
    vec3 vDither = vec3( dot( vec2( 171.0, 231.0 ), vScreenPos.xy ) );
    // shifting r,g & b channels different angles to break the repetition and smooth even more
	vDither.rgb = fract( vDither.rgb / vec3( 103.0, 71.0, 97.0 ) );
    
    //note: apply triangular pdf
    vDither.r = remap_noise_tri_erp(vDither.r)*2.0-1.0;
    vDither.g = remap_noise_tri_erp(vDither.g)*2.0-1.0;
    vDither.b = remap_noise_tri_erp(vDither.b)*2.0-1.0;
    
    return vDither.rgb / colorDepth;
}

vec3 TextureDither(vec2 vScreenPos, float colorDepth)
{
    // creating the dither pattern
    float x = mod(vScreenPos.x/iChannelResolution[2].x, float(iChannelResolution[0]));
    float y = mod(vScreenPos.y/iChannelResolution[2].y, float(iChannelResolution[0]));
    vec3 vDither = texture(iChannel2, vec2(x,y)/RESOLUTIONFACTOR).rrr;
    
    //vec3 finalColor = texture(iChannel0, fragCoord.xy/iResolution.xy).rgb// shifting r,g & b channels different angles to break the repetition and smooth even more
	//vDither.rgb = fract( vDither.rgb / vec3(103.0, 71.0, 97.0) );
    
    //note: apply triangular pdf
    //vDither.r = remap_noise_tri_erp(vDither.r)*2.0-0.5;
    //vDither.g = remap_noise_tri_erp(vDither.g)*2.0-0.5;
    //vDither.b = remap_noise_tri_erp(vDither.b)*2.0-0.5;
    
    return (0.5-vDither);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    if (iFrame % 2 == 1)
        fragColor = vec4(vec3(texture(iChannel0, fragCoord / iResolution.xy).r * 0.5 + 0.5), 1.0);
    else
        fragColor = vec4(vec3(texture(iChannel1, fragCoord / iResolution.xy).r * 0.5 + 0.5), 1.0);
        
    
    float colorDepth = COLORDEPTH;
	// downscaling the resolution so you can appreciate the effect better
    fragCoord = floor(fragCoord /RESOLUTIONFACTOR)*RESOLUTIONFACTOR;
    // getting pixel color from buffer
	vec3 finalColor = fragColor.xyz;
    #if defined ( GREYSCALEINPUT )
    finalColor = finalColor.rrr;
    #endif
    #if defined ( DITHER )
	// applying dithering (left for Valve dither, right for texture dither)
  	if (fragCoord.x < 0.5*iResolution.x)
    finalColor += TextureDither(fragCoord.xy, colorDepth);
    	//finalColor += ValveScreenSpaceDither(fragCoord.xy, colorDepth);
	else 
    	finalColor += TextureDither(fragCoord.xy, colorDepth);
    #endif
    #if defined ( GREYSCALEOUTPUT )
    finalColor = 0.333*vec3(finalColor.r+finalColor.g+finalColor.b);
    #endif
	// limitating color depth and outputing final color
    fragColor = vec4(finalColor,1.0);
    fragColor = vec4(floor(finalColor * colorDepth+0.5) / colorDepth, 1.0);
			
            
    fragColor = vec4(vec3(1.0) - fragColor.xyz,1.0);
    
    ///////////////////////////////
    
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 color1 = vec3(0.0/255.0, 0.0/255.0, 251.0/255.0);			// light color blue
    //vec3 color1 = vec3(247.0/255.0, 238.0/255.0, 87.0/255.0);			// light color yellow
    //vec3 color2 = vec3(1.0/255.0, 1.0/255.0,1.0/255.0);				// dark color blue
    vec3 color2 = vec3(255.0/255.0, 255.0/255.0, 255.0/255.0);			// dark color dark red
    vec3 texColor = fragColor.xyz;	// texture pixel color
    
    
    // set the color based on diagonal texture coord
    //float percent = (uv.x + uv.y) / 2.0;			// percent along an angle
    //vec3 midColor = mix(color1, color2, percent);	// mix of the 2 colors
    
    //vec3 newColor = mix(texColor, midColor, 0.6);	// pixel color mixed
    //vec3 newColor = texColor * (midColor * 1.5);	// pixel color multiplied
    //vec3 newColor = texColor + midColor;			// pixel color added
    
    
    // Replaces the color with a mix of the light and dark color based on the luminance of the original pixel color
    // luminance value
    // https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Shaders/Builtin/Functions/luminance.glsl
    const vec3 W = vec3(0, 0., 1);
    float luminance = dot(texColor, W);
    vec3 lumColor = mix(color1, color2, 1.0 - luminance);
    vec3 newColor = lumColor;			  // light and dark colors
    //vec3 newColor = color1 * luminance; // colorize with 1 color
    
	fragColor = vec4(newColor,1.0);
   }
