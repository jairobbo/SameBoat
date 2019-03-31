//
//  Shaders.metal
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 26/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 fog(float4 position, float4 color) {
    // 1
    float distance = position.z / position.w;
    // 2
    float density = 0.15;
    float fog = 1.0 - clamp(exp(-density * distance), 0.0, 1.0);
    // 3
    float4 fogColor = float4(0.7, 0.7, 0.8, 1);
    color = mix(color, fogColor, fog);
    return color;
}

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(VertexIn vIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &heightFactor [[buffer(2)]],
                             texture2d<float> heightMap [[texture(0)]])
{
    VertexOut vOut;
    constexpr sampler sample;
    float height = heightMap.sample(sample, float2(vIn.uv)).x * heightFactor;
    vIn.position.y = height;
    vOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vIn.position;
    vOut.uv = vIn.uv;
    return vOut;
}

fragment float4 fragment_main(VertexOut vIn [[stage_in]],
                              texture2d<float> linesTexture [[ texture(0)]],
                              texture2d<float> waveTexture [[ texture(1)]],
                              sampler textureSampler [[sampler(0)]])
{
    float entensity = float4(waveTexture.sample(textureSampler, vIn.uv).rgb, 1).x;
    float linesIntensity = 1 - (float4(linesTexture.sample(textureSampler, vIn.uv).rgb, 1).x)/8 ;
    
    float4 color =  float4(0.5 * entensity * linesIntensity, 0.6 * entensity * linesIntensity, 0.7 * entensity * linesIntensity, 1);
    
    return fog(vIn.position, color);
}



