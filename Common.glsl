
float read(sampler2D tex, ivec2 res, ivec2 coord, ivec2 offset, vec4 mouse)
{
    ivec2 r = res;
    ivec2 c = coord + offset;
    
    // is there a better way to mirror the coordinates? :(
    if (c.x < 0)
        c.x = -c.x;
    else if (c.x > r.x)
        c.x = r.x - (c.x - r.x);
        
    if (c.y < 0)
        c.y = -c.y;
    else if (c.y > r.y)
        c.y = r.y - (c.y - r.y);
    
    // is there a way to tell if the mouse is down or not? it seems to get stuck :(
    float ui = clamp(1.0 - length(vec2(c) - mouse.xy) / 15.0, 0.0, 1.0);
    if ( mouse.z < 0.0 && mouse.w < 0.0 ) {
    ui=0.0;
    }
    float h = texelFetch(tex, c, 0).r;
    
    return h + ui;
}

float process(sampler2D bufferIn, sampler2D bufferOut, ivec2 res, vec4 mouse, ivec2 p)
{
    float l = read(bufferIn, res, p, ivec2(-1,  0), mouse);
    float r = read(bufferIn, res, p, ivec2( 1,  0), mouse);
    float u = read(bufferIn, res, p, ivec2( 0, -1), mouse);
    float d = read(bufferIn, res, p, ivec2( 0,  1), mouse);
    
    float c = read(bufferOut, res, p, ivec2(0), mouse);
    
    float damp = 0.98;
    
    return ((l + r + u + d) / 2.0 - c) * damp;
}
