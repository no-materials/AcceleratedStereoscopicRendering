/*
 * Authors: Niko Wissmann
 */

#pragma once
#include "Falcor.h"

using namespace Falcor;

// Camera controller for side-by-side view. Calculates asymmetric view frustum parameters
class StereoCameraController : public CameraController
{
public:

    bool onMouseEvent(const MouseEvent& mouseEvent) override;
    bool onKeyEvent(const KeyboardEvent& keyboardEvent) override;
    bool update() override;
    void attachCamera(const Camera::SharedPtr& pCamera) override;

    Camera::SharedPtr getStereoCamera();

    float ipd = 0.062f;
    float z0 = 2.f;

private:
    bool mIsLeftButtonDown = false;
    bool mIsRightButtonDown = false;
    bool mShouldRotate = false;

    Camera::SharedPtr mpMonoCam;

    // Stereo Camera Parameter
    float fovrad;
    float top;
    float bottom;
    float right;
    float left;
    float offset;
    float4x4 projectionMatLeft;
    float4x4 projectionMatRight;
    float4x4 viewMatLeft;
    float4x4 viewMatRight;

    void setIPD(float ipd) { this->ipd = ipd; }
    void setZ0(float z0) { this->z0 = z0; }
    inline void calcStereoParams();

    glm::vec2 mLastMousePos;
    glm::vec2 mMouseDelta;

    CpuTimer mTimer;

    enum Direction
    {
        Forward,
        Backward,
        Right,
        Left,
        Up,
        Down,
        Count
    };

    std::bitset<Direction::Count> mMovement;

    float mSpeedModifier = 1.0f;
};

