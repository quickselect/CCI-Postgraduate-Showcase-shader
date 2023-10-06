
void mainImage(out vec4 color, in vec2 coord)
{
    if (iFrame == 0)
    {
        color = vec4(vec3(0.0), 1.0);
        return;
    }
    
    ivec2 p = ivec2(coord);
    
    if (iFrame % 2 == 1)
    {
    	color = texelFetch(iChannel0, p, 0);
        return;
    }
    
    ivec2 res = ivec2(iResolution.xy);
    
    float h = process(iChannel1, iChannel0, res, iMouse, p);
    
    color = vec4(h, 0.0, 0.0, 1.0);
}
