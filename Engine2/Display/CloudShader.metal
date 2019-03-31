//
//  ConeShader.metal
//  Engine2
//
//  Created by Jairo Bambang Oetomo on 27/03/2019.
//  Copyright © 2019 Jairo Bambang Oetomo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 fog4(float4 position, float4 color) {
    // 1
    float distance = position.z / position.w;
    // 2
    float density = 0.3;
    float fog = 1.0 - clamp(exp(-density * distance), 0.0, 1.0);
    // 3
    float4 fogColor = float4(0.7, 0.7, 0.8, 1);
    color = mix(color, fogColor, fog);
    return color;
}

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 normal [[ attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut cloud_vertex_main (VertexIn vIn [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut vOut;
    vOut.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vIn.position;
    vOut.color = float4((2 + vIn.position.y)/2,(2 + vIn.position.y)/2,(2 + vIn.position.y)/2,1);
    return vOut;
}

fragment float4 cloud_fragment_main (VertexOut vIn [[stage_in]])
{
    return fog4(vIn.position, vIn.color * float4(0.7, 0.7, 0.8, 1) );
}
