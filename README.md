# Coordinated Hand Movement Sensation – Analysis & Figure Code

This repository contains the **exact MATLAB code and data** used to generate the figures and tables for the manuscript:

**“Coordinated hand movement sensation revealed through an implanted magnetic prosthetic kinesthetic interface.”**

All data in this repository pertain to **participant MKk-P1**. Scripts are organized to **reproduce the manuscript figures** (main and supplementary) from raw `.mat` files with minimal setup.

---

## Repository structure

Myokinetic-Kinesthetic-Interface/ <br />
├─ HandKinematics/ # Joint angle & velocity analysis <br />
│ ├─ kinematics_detection.pynb # Python Jupyter notebook for MediaPipe-based angle extraction<br />
│<br />
├─ HandRenderings/ # 3D visualization of hand shapes<br />
│ ├─ mainSimulator.m # MuJoCo Haptix-based rendering of hand postures<br />
│ ├─ mjhaptix150/ # Supporting resources for MuJoCo Haptix<br />
│<br />
├─ KinestheticHandEvents/ # Parameter search and hand event analysis<br />
│ ├─ HandEventsByWaveform.m # Scatter plots by waveform (sine vs square)<br />
│ ├─ HandSensationSearchSpaceComplete.m # Full parameter-space rendering (Gaussian kernel maps)<br />
│ ├─ HandSensationSearchSpaceNaive.m # Naïve exploration subset<br />
│ ├─ KinestheticData.mat # Data (Amplitude × Frequency × Waveform × Sensation)<br />
│<br />
├─ Likert/ # Likert analysis (Q1–Q4, localization/specificity)<br />
│ ├─ LikertSeparate.m # Phase-separated diverging stacked plots<br />
│ ├─ LikertCombined.m # Combined analysis<br />
│ ├─ LikertAnswers.mat # Collected Likert responses<br />
│<br />
├─ TimeVibrations/ # Perceptual time thresholds<br />
│ ├─ PerceptionTimeAnalysis.m # Computes thresholds from adaptive sequences<br />
│ ├─ StimulationData/<br />
│ ├─ StimulationTimingsSite1.mat<br />
│ ├─ StimulationTimingsSite2.mat<br />
│ ├─ StimulationTimingsSite3.mat<br />
│ ├─ StimulationTimingsSite4.mat<br />
│ ├─ StimulationTimingsSite5.mat<br />
│ ├─ StimulationTimingsSite6.mat<br />
│<br />
├─ VividnessVibrations/ # Amplitude & frequency vividness curves<br />
│ ├─ Vividness_DataAnalysis.m # Fits sigmoid/exponential models to vividness<br />
│ ├─ torqueSensAt90.mat # Torque distribution at 90 Hz<br />
│ ├─ VividnessData/<br />
│ ├─ site1vividData.mat<br />
│ ├─ site1vividDataFreq.mat<br />
│ ├─ site2vividData.mat<br />
│ ├─ site2vividDataFreq.mat<br />
│ ├─ site3vividData.mat<br />
│ ├─ site3vividDataFreq.mat<br />
│ ├─ site4vividData.mat<br />
│ ├─ site4vividDataFreq.mat<br />
│ ├─ site5vividData.mat<br />
│ ├─ site5vividDataFreq.mat<br />
│ ├─ site6vividData.mat<br />
│ ├─ site6vividDataFreq.mat<br />
│<br />
└─ README.md<br />

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
  - [MuJoCo Haptix](https://roboti.us/book/haptix.html) (for `HandRenderings/mainSimulator.m`)

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
