# Coordinated Hand Movement Sensation – Analysis & Figure Code

This repository contains the **exact MATLAB code and data** used to generate the figures and tables for the manuscript:

**“Coordinated hand movement sensation revealed through an implanted magnetic prosthetic kinesthetic interface.”**

All data in this repository pertain to **participant MKk-P1**. Scripts are organized to **reproduce the manuscript figures** (main and supplementary) from raw `.mat` files with minimal setup.

---

## Repository structure

Myokinetic-Kinesthetic-Interface/
├─ HandKinematics/ # Joint angle & velocity analysis
│ ├─ kinematics_detection.pynb # Python Jupyter notebook for MediaPipe-based angle extraction
│
├─ HandRenderings/ # 3D visualization of hand shapes
│ ├─ mainSimulator.m # MuJoCo Haptix-based rendering of hand postures
│ ├─ mjhaptix150/ # Supporting resources for MuJoCo Haptix
│
├─ KinestheticHandEvents/ # Parameter search and hand event analysis
│ ├─ HandEventsByWaveform.m # Scatter plots by waveform (sine vs square)
│ ├─ HandSensationSearchSpaceComplete.m # Full parameter-space rendering (Gaussian kernel maps)
│ ├─ HandSensationSearchSpaceNaive.m # Naïve exploration subset
│ ├─ KinestheticData.mat # Data (Amplitude × Frequency × Waveform × Sensation)
│
├─ Likert/ # Likert analysis (Q1–Q4, localization/specificity)
│ ├─ LikertSeparate.m # Phase-separated diverging stacked plots
│ ├─ LikertCombined.m # Combined analysis
│ ├─ LikertAnswers.mat # Collected Likert responses
│
├─ TimeVibrations/ # Perceptual time thresholds
│ ├─ PerceptionTimeAnalysis.m # Computes thresholds from adaptive sequences
│ ├─ StimulationData/
│ ├─ StimulationTimingsSite1.mat
│ ├─ StimulationTimingsSite2.mat
│ ├─ StimulationTimingsSite3.mat
│ ├─ StimulationTimingsSite4.mat
│ ├─ StimulationTimingsSite5.mat
│ ├─ StimulationTimingsSite6.mat
│
├─ VividnessVibrations/ # Amplitude & frequency vividness curves
│ ├─ Vividness_DataAnalysis.m # Fits sigmoid/exponential models to vividness
│ ├─ torqueSensAt90.mat # Torque distribution at 90 Hz
│ ├─ VividnessData/
│ ├─ site1vividData.mat
│ ├─ site1vividDataFreq.mat
│ ├─ site2vividData.mat
│ ├─ site2vividDataFreq.mat
│ ├─ site3vividData.mat
│ ├─ site3vividDataFreq.mat
│ ├─ site4vividData.mat
│ ├─ site4vividDataFreq.mat
│ ├─ site5vividData.mat
│ ├─ site5vividDataFreq.mat
│ ├─ site6vividData.mat
│ ├─ site6vividDataFreq.mat
│
└─ README.md

---

## Requirements

- **MATLAB** R2023b (earlier versions may work but not tested exhaustively)
- **MATLAB Toolboxes**
  - *Statistics and Machine Learning Toolbox*
  - *Curve Fitting Toolbox*
- **Python (for kinematics_detection.pynb)**
  - Python ≥3.9
  - `mediapipe`, `numpy`, `pandas`, `matplotlib`, `scipy`
- **3rd-party tools**
  - [MuJoCo Haptix](https://mujoco.org/) (for `HandRenderings/mainSimulator.m`)

---

## How to reproduce the manuscript figures

### 1) Hand kinematics (joint angles & velocities)
- Script: `HandKinematics/kinematics_detection.pynb`  
- Uses MediaPipe to estimate angles from video, compares MKk-P1 vs TMRk datasets.  
- Manuscript: Fig. 3C-F,J-M and Fig. S3 (joint angle subtraction, velocity correlations).

### 2) Hand renderings
- Script: `HandRenderings/mainSimulator.m`  
- Generates 3D MuJoCo Haptix visualizations of hand shapes (open/close percepts).  
- Manuscript: Fig. 3G–I (rendered hand shapes).

### 3) Kinesthetic hand events
- Scripts: `HandEventsByWaveform.m`, `HandSensationSearchSpaceComplete.m`, `HandSensationSearchSpaceNaive.m`  
- Data: `KinestheticHandEvents/KinestheticData.mat`  
- Manuscript: Fig. 2B and Fig. S2A,B (search-space scatter maps and Gaussian density maps).

### 4) Likert analysis
- Scripts: `LikertCombined.m`, `LikertSeparate.m`  
- Data: `LikertAnswers.mat`  
- Manuscript: Fig. 4, Fig. S4 (localization/specificity answers).

### 5) Time thresholds
- Script: `TimeVibrations/PerceptionTimeAnalysis.m`  
- Data: `StimulationData/*.mat`  
- Manuscript: Fig. 5A–B; Fig. S5.

### 6) Vividness analysis
- Script: `VividnessVibrations/Vividness_DataAnalysis.m`  
- Data: `VividnessData/*.mat`, `torqueSensAt90.mat`  
- Manuscript: Fig. 5C–D; Fig. S6.

---

## Citation

If you use this code or data, please cite:

> Masiero F., Gentile M., Gherardini M., La Frazia E., Moore C. H., Kilic B. Ü., Ianniciello V., Reho R., Mori T., Paggetti F., Andreani L., Whitton S. A., Marasco P. D., Cipriani C.  
> *Coordinated hand movement sensation revealed through an implanted magnetic prosthetic kinesthetic interface.* [Journal / year / DOI]

---

## License

- **Code**: MIT License  
- **Data**: research-only, non-commercial use

---

## Contact

For questions or issues:
- Open a GitHub issue, or  
- Contact the corresponding authors listed in the manuscript.
