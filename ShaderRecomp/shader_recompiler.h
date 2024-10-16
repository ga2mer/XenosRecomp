#pragma once

#include "shader.h"
#include "shader_code.h"

struct ShaderRecompiler
{
    std::string out;
    uint32_t indentation = 0;
    bool isPixelShader = false;
    const uint8_t* constantTableData = nullptr;
    std::unordered_map<uint32_t, VertexElement> vertexElements;
    std::unordered_map<uint32_t, std::string> interpolators;
    std::unordered_map<uint32_t, const ConstantInfo*> float4Constants;
    std::unordered_map<uint32_t, const char*> boolConstants;
    std::unordered_map<uint32_t, const char*> samplers;

    void indent()
    {
        for (uint32_t i = 0; i < indentation; i++)
            out += '\t';
    }

    template<class... Args>
    void print(std::format_string<Args...> fmt, Args&&... args)
    {
        std::vformat_to(std::back_inserter(out), fmt.get(), std::make_format_args(args...));
    }

    template<class... Args>
    void println(std::format_string<Args...> fmt, Args&&... args)
    {
        std::vformat_to(std::back_inserter(out), fmt.get(), std::make_format_args(args...));
        out += '\n';
    }

    void printDstSwizzle(uint32_t dstSwizzle, bool operand);
    void printDstSwizzle01(uint32_t dstRegister, uint32_t dstSwizzle);

    void recompile(const VertexFetchInstruction& instr, uint32_t address);
    void recompile(const TextureFetchInstruction& instr);
    void recompile(const AluInstruction& instr);

    void recompile(const uint8_t* shaderData);
};