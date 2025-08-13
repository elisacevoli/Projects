# 3D Face Identification for Clinical Patient Registration

Machine learning pipeline for **3D facial identification** in healthcare admission using geometric features from RGB-D images, achieving **98% recognition rate** with **0% False Acceptance Rate**.

## Overview

Contactless patient registration system that leverages 3D facial recognition to streamline healthcare admission processes. The system matches patients to pre-registered Electronic Health Records (EHR) through secure facial biometric identification.

## Results

| Metric | Value |
|--------|-------|
| **Recognition Rate** | 98% |
| **False Acceptance Rate** | 0% |
| **Genuine Acceptance Rate** | 97% |
| **False Reject Rate** | 3% |

## Approach

- **Datasets**: Bosphorus 3D Face DB (27 subjects), Intel RealSense acquisitions (8 subjects)
- **Input**: RGB-D images (640×480, Intel RealSense SR305)
- **Features**: 52 Euclidean distances + 159 geometric descriptors
- **Workflow**:
  - 3D landmark extraction (MediaPipe + manual annotation)
  - Sellion estimation via Gaussian curvature analysis
  - Fisher Score feature selection (30 features)
  - Multi-classifier evaluation: SVM, kNN, Random Forest, MLP
- **Best Model**: SVM with RBF kernel (C=100)
- **Security**: Custom decision thresholds for open-set recognition

## Project Structure

### Scripts (Python/MATLAB)
- `compute_3D_euclidean_distances.ipynb` - Distance calculations
- `Dataset_Constructor.m` - Dataset preparation
- `descriptors_primary_derived.m` - Geometric descriptors computation
- `extract_features_bin.m` - Feature binning and extraction
- `extraction_landmark.m` - 3D landmark detection
- `features_extraction.m` - Complete feature extraction pipeline
- `ml_classification_pipeline.py` - ML training and evaluation

### Unity Demo
- `DemoUnity.mp4` - Interactive 3D visualization prototype

## Technologies

**Processing**: Python, MATLAB, MediaPipe  
**3D Modeling**: MeshLab, Blender  
**Visualization**: Unity 3D  
**Hardware**: Intel RealSense SR305 depth sensor
