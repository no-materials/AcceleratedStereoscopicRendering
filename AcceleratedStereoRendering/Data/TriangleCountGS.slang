/*
 * Authors: Niko Wissmann
 */

RWStructuredBuffer<int> gTriangleCount;

struct VertexOutput
{
    float3 posW : POSW;
    float4 posH : SV_POSITION;
    float2 texC : TEXCRD;
    float occFlag : DOCCFLAG;
};

struct GeometryOut
{
    VertexOutput vsOut;
};

[maxvertexcount(3)]
void main(triangle VertexOutput input[3], inout TriangleStream<GeometryOut> outStream)
{
    GeometryOut gsOut;

    InterlockedAdd(gTriangleCount[0], 1);

    for (int i = 0; i < 3; i++)
    {
        gsOut.vsOut = input[i];
        outStream.Append(gsOut);
    }
    outStream.RestartStrip();
}
