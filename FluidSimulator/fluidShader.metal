//
//  fluidShader.metal
//  FluidSimulator
//
//  Created by Jean-Baptiste Agostin on 31/10/2024.
//
#include <metal_stdlib>
using namespace metal;

kernel void fluidShader(texture2d<float, access::write> outTexture [[texture(0)]],
                        constant float &time [[buffer(0)]],
                        uint2 id [[thread_position_in_grid]]) {
    float2 uv = float2(id) / float2(outTexture.get_width(), outTexture.get_height());
    float red = 0.5 + 0.5 * cos(time + uv.x * 3.0);
    float green = 0.5 + 0.5 * sin(time + uv.y * 3.0);
    float blue = 0.5 + 0.5 * cos(uv.x * 10.0 + uv.y * 10.0 + time);
    
    float4 fluidColor = float4(red, green, blue, 1.0);
    outTexture.write(fluidColor, id);
}
