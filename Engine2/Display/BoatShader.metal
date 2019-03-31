//
//  ConeShader.metal
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 27/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 fog2(float4 position, float4 color) {
    // 1
    float distance = position.z / position.w;
    // 2
    float density = 0.1;
    float fog = 1.0 - clamp(exp(-density * distance), 0.0, 1.0);
    // 3
    float4 fogColor = float4(0.7, 0.7, 0.8, 1);
    color = mix(color, fogColor, fog);
    return color;
}

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 normal [[ attribute(1)]];
    float2 uv [[attribute(2)]];
    float4 color [[attribute(3)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 normal;
    float2 uv;
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};



vertex VertexOut boat_vertex_main (VertexIn vIn [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut vOut;
    vOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vIn.position;
    vOut.normal = vIn.normal;
    vOut.uv = vIn.uv;
    vOut.color = vIn.color;
    return vOut;
}

fragment float4 boat_fragment_main (VertexOut vIn [[stage_in]],
                                    texture2d<float> boatTexture [[texture(0)]],
                                    sampler textureSampler [[sampler(0)]])
{
    float4 base =  float4(boatTexture.sample(textureSampler, vIn.uv).rgb, 1);
    return fog2(vIn.position, base * vIn.color);
}
