/*
 * Authors: Niko Wissmann
 */

struct VertexIn
{
    float4 pos : POSITION;
    float2 texC : TEXCOORD;
    float quadId : QUADID;
};

struct HS_Input
{
    float3 posW : POSW;
    float quadId : QUADID;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
};

Texture2D gDepthTex;
Texture2D gLeftEyeTex;

HS_Input main(VertexIn vIn)
{
    HS_Input hsOut;

    hsOut.posW = vIn.pos.xyz;
    hsOut.posH = vIn.pos;
    hsOut.texC = vIn.texC;
    hsOut.quadId = vIn.quadId;

    return hsOut;
}
