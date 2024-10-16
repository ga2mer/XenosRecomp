#define FLT_MIN asfloat(0xff7fffff)
#define FLT_MAX asfloat(0x7f7fffff)

#ifdef __spirv__

struct PushConstants
{
    uint64_t VertexShaderConstants;
    uint64_t PixelShaderConstants;
    uint64_t SharedConstants;
};

[[vk::push_constant]] ConstantBuffer<PushConstants> g_PushConstants;

#define CONSTANT_BUFFER(NAME, REGISTER) struct NAME
#define PACK_OFFSET(REGISTER)

#define GET_CONSTANT(NAME) constants.NAME
#define GET_SHARED_CONSTANT(NAME) sharedConstants.NAME

#else

#define CONSTANT_BUFFER(NAME, REGISTER) cbuffer NAME : register(REGISTER, space4)
#define PACK_OFFSET(REGISTER) : packoffset(REGISTER)

#define GET_CONSTANT(NAME) NAME
#define GET_SHARED_CONSTANT(NAME) NAME

#endif

#define INPUT_LAYOUT_FLAG_HAS_R11G11B10_NORMAL (1 << 0)

#define SHARED_CONSTANTS \
    [[vk::offset(128)]] uint g_AlphaTestMode PACK_OFFSET(c8.x); \
    [[vk::offset(132)]] float g_AlphaThreshold PACK_OFFSET(c8.y); \
    [[vk::offset(136)]] uint g_Booleans PACK_OFFSET(c8.z); \
    [[vk::offset(140)]] uint g_SwappedTexcoords PACK_OFFSET(c8.w); \
    [[vk::offset(144)]] uint g_InputLayoutFlags PACK_OFFSET(c9.x)

Texture2D<float4> g_Texture2DDescriptorHeap[] : register(t0, space0);
Texture3D<float4> g_Texture3DDescriptorHeap[] : register(t0, space1);
TextureCube<float4> g_TextureCubeDescriptorHeap[] : register(t0, space2);
SamplerState g_SamplerDescriptorHeap[] : register(s0, space3);

float4 tfetch2D(uint resourceDescriptorIndex, uint samplerDescriptorIndex, float2 texCoord)
{
    return g_Texture2DDescriptorHeap[resourceDescriptorIndex].Sample(g_SamplerDescriptorHeap[samplerDescriptorIndex], texCoord);
}

float4 tfetch3D(uint resourceDescriptorIndex, uint samplerDescriptorIndex, float3 texCoord)
{
    return g_Texture3DDescriptorHeap[resourceDescriptorIndex].Sample(g_SamplerDescriptorHeap[samplerDescriptorIndex], texCoord);
}

float4 tfetchCube(uint resourceDescriptorIndex, uint samplerDescriptorIndex, float4 texCoord)
{
    return g_TextureCubeDescriptorHeap[resourceDescriptorIndex].Sample(g_SamplerDescriptorHeap[samplerDescriptorIndex], texCoord.xyz);
}

float4 tfetchR11G11B10(uint inputLayoutFlags, uint4 value)
{
    if (inputLayoutFlags & INPUT_LAYOUT_FLAG_HAS_R11G11B10_NORMAL)
    {
        return float4(
            (value.x & 0x00000400 ? -1.0 : 0.0) + ((value.x & 0x3FF) / 1024.0),
            (value.x & 0x00200000 ? -1.0 : 0.0) + (((value.x >> 11) & 0x3FF) / 1024.0),
            (value.x & 0x80000000 ? -1.0 : 0.0) + (((value.x >> 22) & 0x1FF) / 512.0),
            0.0);
    }
    else
    {
        return asfloat(value);
    }
}

float4 tfetchTexcoord(uint swappedTexcoords, float4 value, uint semanticIndex)
{
    return (swappedTexcoords & (1 << semanticIndex)) != 0 ? value.yxwz : value;
}

