/*
 * Authors: Niko Wissmann
 */

import ShaderCommon;
import Shading;
import Utils;

#define LeftEye         0
#define RightEye        1

#define NUM_LIGHTSOURCES 1

cbuffer PerImageCB
{
    uint gStereoTarget;
    float4x4 gLightViewProj;
    float gBias;
    uint gKernelSize;
};

SamplerComparisonState gPCFCompSampler;

ITexture2D gPos;
ITexture2D gNorm;
ITexture2D gDiffuseMatl;
ITexture2D gSpecMatl;

Texture2D gShadowMap;

// PCF Shadow Factor
float getShadowFactor(float3 posW)
{
    float4 pixelLight = mul(float4(posW, 1), gLightViewProj);
    pixelLight /= pixelLight.w;

    float2 texC = float2(pixelLight.x, -pixelLight.y) * 0.5 + 0.5;
    pixelLight.z -= gBias;

    float w, h;
    gShadowMap.GetDimensions(w, h);
    float xOffset = 1.0 / w;
    float yOffset = 1.0 / h;

    float kernelSize = gKernelSize - 1;
    float halfKernelSize = kernelSize / 2.0;

    float factor = 0.0;
    for (float y = -halfKernelSize; y <= halfKernelSize; y += 1.0)
    {
        for (float x = -halfKernelSize; x <= halfKernelSize; x += 1.0)
        {
            float2 offsetTexC = texC + float2(x * xOffset, y * yOffset);
            factor += gShadowMap.SampleCmpLevelZero(gPCFCompSampler, offsetTexC, pixelLight.z);
        }
    }

    return saturate(factor / (kernelSize * kernelSize));
}

float3 shade(float3 camPosW, uint2 pixelPos, float3 posW, float3 normalW, float4 albedo, float4 specular)
{
    if (albedo.a <= 0)
    {
        discard;
    }

    ShadingData sd = reconstructShadingData(camPosW, posW, normalW, albedo, specular);
    float4 shadingColor = float4(0, 0, 0, 1);

    for (uint l = 0; l < gLightsCount; l++)
    {
        float shadowFactor = 1;
        if (l == 0)
        {
            shadowFactor = getShadowFactor(posW);
        }
#ifdef _SHOWBRDF
        shadingColor.rgb = float3(evalMaterial(sd, gLights[l], shadowFactor).specularBrdf);
#else
        shadingColor.rgb += evalMaterial(sd, gLights[l], shadowFactor).color.rgb;
#endif
    }

#ifndef _SHOWBRDF // if not
    shadingColor.rgb += evalMaterial(sd, gLightProbe).color.rgb;
#endif

    return shadingColor.rgb;
}

[earlydepthstencil]
float4 main(float2 texC : TEXCOORD, float4 pos : SV_Position) : SV_Target0
{
    uint2 pixelPos = (uint2) pos.xy;

    float3 posW = gPos[pixelPos].rgb;
    float3 normalW = gNorm[pixelPos].rgb;
    float4 albedo = gDiffuseMatl[pixelPos];
    float4 specular = gSpecMatl[pixelPos];

    float3 outputColor;
    if(gStereoTarget == LeftEye)
        outputColor = shade(gCamera.posWLeft, pixelPos, posW, normalW, albedo, specular);
    else
        outputColor = shade(gCamera.posWRight, pixelPos, posW, normalW, albedo, specular);

    return float4(outputColor, 1);
}
