/*
 * Authors: Niko Wissmann, Martin Misiak
 */

#define QUAD_SIZE 16

Texture2D gDepthTex;
Texture2D gNormalTex;
Texture2D gPositionTex;
RWStructuredBuffer<float> gDiffResult;

cbuffer ComputeCB
{
    uint gQuadSizeX;
    float gNearZ;
    float gFarZ;
    float3 gCamPos;
};

float linearDepth(float depth)
{
    return gNearZ / (gFarZ - depth * (gFarZ - gNearZ)) * gFarZ;
}

groupshared float2 depth[QUAD_SIZE * QUAD_SIZE];
groupshared float3 normalsMin[QUAD_SIZE * QUAD_SIZE];
groupshared float3 normalsMax[QUAD_SIZE * QUAD_SIZE];

[numthreads(QUAD_SIZE, QUAD_SIZE, 1)]
void main(uint3 groupId : SV_GroupID, uint3 groupThreadId : SV_GroupThreadId, uint groupIndex : SV_GroupIndex)
{
    uint2 posStart = groupId.xy * QUAD_SIZE;
    uint2 crd = posStart + groupThreadId.xy;
    uint outputIndex = groupId.y * gQuadSizeX + groupId.x;

    depth[groupIndex]      = gDepthTex[crd].r;
    normalsMin[groupIndex] = gNormalTex[crd].xyz;
    normalsMax[groupIndex] = gNormalTex[crd].xyz;

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 128)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 128].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 128].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 128]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 128]);
    }

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 64)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 64].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 64].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 64]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 64]);
    }

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 32)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 32].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 32].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 32]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 32]);
    }

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 16)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 16].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 16].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 16]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 16]);
    }

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 8)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 8].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 8].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 8]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 8]);
    }
    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 4)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 4].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 4].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 4]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 4]);
    }
    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 2)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 2].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 2].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 2]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 2]);
    }

    GroupMemoryBarrierWithGroupSync();

    if (groupIndex < 1)
    {
        depth[groupIndex].x = max(depth[groupIndex].x, depth[groupIndex + 1].x);
        depth[groupIndex].y = min(depth[groupIndex].y, depth[groupIndex + 1].y);

        normalsMin[groupIndex] = min(normalsMin[groupIndex], normalsMin[groupIndex + 1]);
        normalsMax[groupIndex] = max(normalsMax[groupIndex], normalsMax[groupIndex + 1]);
    }

    if (groupIndex == 0)
    {
#ifdef _BINOCULAR_METRIC
         float minDepth = linearDepth(depth[0].y);
         float maxDepth = linearDepth(depth[0].x);
         float angleMin = 2*atan(0.065/(2*minDepth));
         float angleMax = 2*atan(0.065/(2*maxDepth));

         float disparity = abs(angleMin - angleMax);
         float disparityArcMinutes = (disparity/3.14159)*180 * 60;

        float3 normalDifference = normalsMax[0] - normalsMin[0];
        float normalSpread = dot(normalDifference, normalDifference);

        /*
        if(normalSpread < 0.01f)
        {
            float3 toCamVec   = normalize(gCamPos - gPositionTex[crd].xyz);
            float scaleFactor = 1.0 / dot(toCamVec, normalsMin[0]);
            scaleFactor = sqrt(scaleFactor);
            if(maxDepth/minDepth < (scaleFactor*0.9f))
                disparityArcMinutes = 0;
        }
        */
        

         gDiffResult[outputIndex] =  disparityArcMinutes;
#else
         gDiffResult[outputIndex] = (depth[0].y / depth[0].x);
#endif
    }
        
}
