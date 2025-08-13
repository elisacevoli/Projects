# PolypGen Challenge: Automated Polyp Segmentation

Fine-tuned **DeepLabv3+ (ResNet50)** for automatic polyp segmentation in colonoscopic images achieving **DSC=71.51%** on the PolypGen dataset.

## Overview

Automated polyp detection system for colorectal cancer prevention using deep learning. The model processes colonoscopy images to segment polyps with high accuracy, supporting gastroenterologists in clinical diagnosis.

## Results

| Metric | Value |
|--------|-------|
| **DSC** | 71.51% |
| **IoU** | 64.44% |
| **Precision** | 76.32% |
| **Recall** | 71.90% |

## Approach

- **Model**: DeepLabv3+ with ResNet50 backbone
- **Dataset**: PolypGen (2,911 positive, 1,137 negative frames)
- **Input**: 256×256 colonoscopy images
- **Training**: SGD optimizer, Cross Entropy Loss (9:1 weights)
- **Preprocessing**:
  - Multi-color-space cropping (LAB/HSV)
  - Specular highlight removal
  - Gamma correction (γ=1.2)
  - Class balancing
- **Post-processing**:
  - Morphological hole filling
  - Small area filtering  
  - Dilation (disk=3, 2 iterations)

## Files

- `config.py` - Configuration parameters
- `TRAINING.ipynb` - Model training
- `TESTING.ipynb` - Evaluation and testing

## Usage

1. Configure paths in `config.py`
2. Run `TRAINING.ipynb` to train the model
3. Use `TESTING.ipynb` for evaluation
