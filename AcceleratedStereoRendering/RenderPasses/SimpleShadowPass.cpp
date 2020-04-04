/*
 * Authors: Niko Wissmann
 */

#include "SimpleShadowPass.h"

SimpleShadowPass::SharedPtr SimpleShadowPass::create(const Dictionary & dict)
{
    SharedPtr pPass = SharedPtr(new SimpleShadowPass);
    return pPass;
}

SimpleShadowPass::SimpleShadowPass() : RenderPass("SimpleShadowPass")
{
    mpGraphicsState = GraphicsState::create();
    mpLightCamera = Camera::create();
    mRaster.pProgram = GraphicsProgram::createFromFile("SimpleShadowPass.slang", "vs", "ps");
    mRaster.pState = GraphicsState::create();
    mRaster.pVars = GraphicsVars::create(mRaster.pProgram->getReflector());
    mRaster.pState->setProgram(mRaster.pProgram);
    RasterizerState::Desc rsDesc;
    rsDesc.setCullMode(RasterizerState::CullMode::None);
    mRaster.pState->setRasterizerState(RasterizerState::create(rsDesc));

    mpFbo = Fbo::create();
}

RenderPassReflection SimpleShadowPass::reflect() const
{
    RenderPassReflection r;
    r.addOutput("depthStencil", "Depth and Stencil from light source").texture2D(mShadowMapSize, mShadowMapSize).format(ResourceFormat::D32Float).bindFlags(Resource::BindFlags::DepthStencil).mipLevels(1);
    return r;
}

void SimpleShadowPass::createShadowMatrix(const DirectionalLight* pLight, glm::mat4& shadowVP)
{
    glm::vec3 center = mpScene->getBoundingBox().center;

    float radius = 0;
    radius = max(mpScene->getBoundingBox().extent.x, radius);
    radius = max(mpScene->getBoundingBox().extent.y, radius);
    radius = max(mpScene->getBoundingBox().extent.z, radius);
    radius += mAABRadiusPadding;

    glm::mat4 view = glm::lookAt(center, center + pLight->getWorldDirection(), glm::vec3(0, 1, 0));
    glm::mat4 proj = glm::ortho(-radius, radius, -radius, radius, -radius, radius);

    shadowVP = proj * view;
}

void SimpleShadowPass::execute(RenderContext * pContext, const RenderData * pRenderData)
{
    if (mpSceneRenderer == nullptr)
    {
        logWarning("Invalid SceneRenderer in SimpleShadowPass::execute()");
        return;
    }

    if (mbEnableShadows && mpDirectionalLight != nullptr)
    {
        if (mbShadowMatDirty)
        {
            mpFbo->attachDepthStencilTarget(pRenderData->getTexture("depthStencil"));
            pContext->clearFbo(mpFbo.get(), vec4(0), 1.f, 0, FboAttachmentType::All);

            createShadowMatrix(mpDirectionalLight.get(), mShadowMat);
            mpLightCamera->setProjectionMatrix(mShadowMat);
            mLastLightDirW = mpDirectionalLight->getWorldDirection();
            mbShadowMatDirty = false;
            mRaster.pState->setFbo(mpFbo);
            pContext->setGraphicsState(mRaster.pState);
            pContext->setGraphicsVars(mRaster.pVars);
            mpSceneRenderer->renderScene(pContext, mpLightCamera.get());
        }
        compareLightDirections();
    }
    else
    {
        mpFbo->attachDepthStencilTarget(pRenderData->getTexture("depthStencil"));
        pContext->clearFbo(mpFbo.get(), vec4(0), 1.f, 0, FboAttachmentType::All);
    }
}

void SimpleShadowPass::renderUI(Gui * pGui, const char * uiGroup)
{
    if (pGui->addCheckBox("Enable Shadows", mbEnableShadows))
    {
        mbShadowMatDirty = true;
    }
    if (mbEnableShadows)
    {
        pGui->addIntVar("Shadow Map Size", mShadowMapSize, 0, 8192);
        if (pGui->addButton("Update Size"))
        {
            mpMainRenderObject->onClickResize();
        }
        if (pGui->addFloatVar("Ortho Padding", mAABRadiusPadding, -25.f, 100.f))
        {
            mpMainRenderObject->onClickResize();
        }
    }
}

Dictionary SimpleShadowPass::getScriptingDictionary() const
{
	return Dictionary();
}

void SimpleShadowPass::onResize(uint32_t width, uint32_t height)
{
    mbShadowMatDirty = true;
}

void SimpleShadowPass::setScene(const std::shared_ptr<Scene>& pScene)
{
    mpDirectionalLight = nullptr;
    mpScene = pScene;
    mpSceneRenderer = SceneRenderer::create(mpScene);
    if (mpScene != nullptr && mpScene->getLight(0)->getType() == LightDirectional)
    {
        mpDirectionalLight = std::dynamic_pointer_cast<DirectionalLight>(mpScene->getLight(0));
        mLastLightDirW = mpDirectionalLight->getWorldDirection();
        mbShadowMatDirty = true;
    }
}

void SimpleShadowPass::compareLightDirections()
{
    float eps = 0.01f;
    mbShadowMatDirty = (
            abs(mLastLightDirW.x - mpDirectionalLight->getWorldDirection().x) > eps ||
            abs(mLastLightDirW.y - mpDirectionalLight->getWorldDirection().y) > eps ||
            abs(mLastLightDirW.z - mpDirectionalLight->getWorldDirection().z) > eps
        );
}

