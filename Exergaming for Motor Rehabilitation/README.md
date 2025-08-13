# Exergaming for Motor Rehabilitation

Interactive rehabilitation games that combine exercise and entertainment to improve patient motor skills through real-time pose tracking and personalized feedback.

## Overview

This project develops exergames for motor rehabilitation featuring:
- **Real-time patient tracking** via webcam and OpenPose (CNN-based pose recognition)
- **Three rehabilitation exercises**: balance, motor control, and lower-limb strength
- **Personalized workspace** based on anatomical metrics
- **Audiovisual feedback** to maximize engagement
- **Clinical reporting** for progress assessment

## Project Structure

### Core Scripts
- **Project06_X_ELCE.m**: Main execution scripts (X = 1,2,3)
- **Project06_X_ELCE_offline.m**: Offline processing scripts
- **CoM_computation.m**: Center of mass calculation
- **joint_distance.m**: Joint distance utilities
- **gameOver.m**: End-of-session feedback
- **INVERT_IMG.m**: Image preprocessing

### Folders
- **feedback/**: Additional feedback modules and resources

### Demo & Assets
- **Balance Training Demo**: https://youtu.be/CsVNlnK-YJM
- **Motor Control Demo**: https://youtu.be/iRfhNMrGS0w
- **Strength Training Demo**: https://youtu.be/qPzVAbYA5as

## Quick Start

1. Run desired experiment: `Project06_X_ELCE.m`
2. Position in front of webcam
3. Follow red targets with your center of mass (blue dot becomes green when successful)
4. Complete 10 targets or 3-minute session
5. Review generated clinical report

## Exercises

- **E1 - Balance Training**: Improve stability by shifting center of mass horizontally while keeping feet stationary. Targets the hip and ankle control mechanisms essential for postural balance.
- **E2 - Motor Control**: Enhance coordination through lateral stepping movements. Focuses on gait training and weight transfer skills critical for daily mobility.
- **E3 - Strength Training**: Build lower-limb muscle strength through controlled squatting motions. Targets anti-gravitational muscles for improved functional capacity.

## Requirements

- MATLAB with Computer Vision Toolbox
- Webcam (min 640x480)
- OpenPose integration
- Well-lit environment

## Clinical Metrics

Tracks reachable workspace, target achievement speed, session duration, success rate, and movement patterns for rehabilitation assessment.
