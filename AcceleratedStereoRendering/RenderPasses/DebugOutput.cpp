/*
 * Authors: Niko Wissmann
 */

#include "DebugOutput.h"

namespace {
    const char* kFileOutput = "DebugOutput.slang";
};

DebugOutput::SharedPtr DebugOutput::create(const Dictionary &params)
{
    DebugOutput::SharedPtr ptr(new DebugOutput());
    return ptr;
}

RenderPassReflection DebugOutput::reflect() const
{
    RenderPassReflection r;
    r.addInput("posW", "");
    r.addInput("normW", "");
    r.addInput("diffuseOpacity", "");
    r.addInput("specRough", "");
    r.addInput("depth", "");

    r.addOutput("out", "").format(ResourceFormat::RGBA32Float).bindFlags(Resource::BindFlags::ShaderResource | Resource::BindFlags::UnorderedAccess | Resource::BindFlags::RenderTarget);
    return r;
}

void DebugOutput::initialize(const Dictionary & dict)
{
    mpState = GraphicsState::create();
    mpPass = FullScreenPass::create(kFileOutput);
    mpVars = GraphicsVars::create(mpPass->getProgram()->getReflector());
    mpFbo = Fbo::create();

    mIsInitialized = true;
}

void DebugOutput::execute(RenderContext * pContext, const RenderData * pRenderData)
{
    // On first execution, run some initialization
    if (!mIsInitialized) initialize(pRenderData->getDictionary());

    // Get our output buffer and clear it
    const auto& pDisTex = pRenderData->getTexture("out");
    pContext->clearUAV(pDisTex->getUAV().get(), vec4(0));
    mpFbo->attachColorTarget(pDisTex, 0);

    if (pDisTex == nullptr) return;

    mpVars["PerImageCB"]["gDebugMode"] = (uint32_t)mDebugMode;
    mpVars["PerImageCB"]["gDepthRange"] = glm::vec2(mpScene->getActiveCamera()->getNearPlane(), mpScene->getActiveCamera()->getFarPlane());
    mpVars["PerImageCB"]["gStereoOn"] = root->sidebyside ? (uint)1 : (uint)0;
    mpVars["PerImageCB"]["gZ0"] = root->getZ0();

    mpVars->setTexture("gPos", pRenderData->getTexture("posW"));
    mpVars->setTexture("gNorm", pRenderData->getTexture("normW"));
    mpVars->setTexture("gDiffuseMatl", pRenderData->getTexture("diffuseOpacity"));
    mpVars->setTexture("gSpecMatl", pRenderData->getTexture("specRough"));
    mpVars->setTexture("depthBuf", pRenderData->getTexture("depth"));

    mpState->setFbo(mpFbo);
    pContext->pushGraphicsState(mpState);
    pContext->pushGraphicsVars(mpVars);
    mpPass->execute(pContext);
    pContext->popGraphicsVars();
    pContext->popGraphicsState();
}

void DebugOutput::renderUI(Gui * pGui, const char * uiGroup)
{
    Gui::DropdownList debugModeList;
    debugModeList.push_back({ 1, "Positions" });
    debugModeList.push_back({ 2, "Normals" });
    debugModeList.push_back({ 3, "Diffuse Mat" });
    debugModeList.push_back({ 4, "Specular Mat" });
    debugModeList.push_back({ 5, "Linear Roughness" });
    debugModeList.push_back({ 6, "Z-Buffer" });
    pGui->addDropdown("Debug Shading", debugModeList, (uint32_t&)mDebugMode);
}

Dictionary DebugOutput::getScriptingDictionary() const
{
    return Dictionary();
}

void DebugOutput::onResize(uint32_t width, uint32_t height)
{
}

void DebugOutput::setScene(const std::shared_ptr<Scene>& pScene)
{
    mpScene = pScene;
}
