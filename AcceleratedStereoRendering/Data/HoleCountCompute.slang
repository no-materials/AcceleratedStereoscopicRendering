/*
 * Authors: Niko Wissmann
 */

Texture2D gInputTex;
RWStructuredBuffer<int> gCHCBuffer;

groupshared float pixAlphas[16][16];

// Counts all pixel holes per frame - not very fast, but it works

[numthreads(16, 16, 1)]
void main(uint3 groupId : SV_GroupID, uint3 groupThreadId : SV_GroupThreadId)
{
    uint2 inputDim;
    gInputTex.GetDimensions(inputDim.x, inputDim.y);

    uint2 posStart = groupId.xy * 16;
    uint2 crd = posStart + groupThreadId.xy;

    pixAlphas[groupThreadId.x][groupThreadId.y] = gInputTex[crd].a;

    GroupMemoryBarrierWithGroupSync();

    if (any(groupThreadId) == false)
    {
        for (int i = 0; i < 16; i++)
        {
            for (int j = 0; j < 16; j++)
            {
                if (crd.x + i >= inputDim.x || crd.y + j >= inputDim.y)
                    break;

                if (pixAlphas[i][j] == 0)
                {
                    InterlockedAdd(gCHCBuffer[0], 1);
                }
            }
        }
    }
}
