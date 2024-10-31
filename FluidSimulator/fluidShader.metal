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

    
    float z = 0.5 * sin(time * 0.5) + 0.5; 

    
    float red = 0.5 + 0.5 * sin(uv.x * 10.0 + time + z * 5.0);
    float green = 0.5 + 0.5 * cos(uv.y * 10.0 + time + z * 5.0);
    float blue = 0.5 + 0.5 * sin(uv.x * uv.y * 20.0 + z * 10.0);


    float4 color = float4(red, green, blue, 1.0);
    outTexture.write(color, id);
}
