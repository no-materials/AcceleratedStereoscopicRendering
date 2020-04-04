/*
 * Authors: Niko Wissmann
 */

import ShaderCommon;
import Shading;

cbuffer PerImageCB
{
    float2 gDepthRange;
    uint gDebugMode;
    uint gStereoOn;
    float gZ0;
};

#define Pos         1
#define Normals     2
#define DiffMat     3
#define SpecMat     4
#define LinearRough 5

float linearizeDepth(float z)
{
    float zNear = gDepthRange.x;
    float zFar = gDepthRange.y;
    float depth = z;
    return (2.0 * zNear) / (zFar + zNear - depth * (zFar - zNear));
}

float3 shade(float3 posW, float3 normalW, float linearRoughness, float4 albedo, float3 spec, float z)
{
    // Discard empty pixels
    if (albedo.a <= 0)
    {
        discard;
    }

    float z_lin = linearizeDepth(z);
    float3 result;

    if (gDebugMode == Pos)
        result = posW;
    else if (gDebugMode == Normals)
        result = 0.5 * normalW + 0.5f;
    else if (gDebugMode == DiffMat)
        result = albedo.rgb;
    else if (gDebugMode == SpecMat)
        result = spec;
    else if (gDebugMode == LinearRough)
        result = float3(linearRoughness);
    else
    {
        result = float3(z_lin);
    }

    if (gStereoOn == 1 && z_lin > gZ0 / gDepthRange.y && z_lin < (gZ0 + 0.1f) / gDepthRange.y)
        result = float3(1);

    return result;
}

ITexture2D gPos;
ITexture2D gNorm;
ITexture2D gDiffuseMatl;
ITexture2D gSpecMatl;
ITexture2D depthBuf;

float4 main(float2 texC : TEXCOORD, float4 pos : SV_Position) : SV_Target0
{
    uint2 pixelPos = (uint2) pos.xy;

    float3 posW = gPos[pixelPos].rgb;
    float3 normalW = gNorm[pixelPos].rgb;
    float4 albedo = gDiffuseMatl[pixelPos];
    float4 spec = gSpecMatl[pixelPos];
    float z = depthBuf[pixelPos].r;

    float3 color = shade(posW, normalW, spec.a, albedo, spec.rgb, z);

    return float4(color, 1);
}
