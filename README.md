# Coordinated Hand Movement Sensation – Analysis & Figure Code

This repository contains the **exact MATLAB code and data** used to generate the figures and tables for the manuscript:

**“Coordinated hand movement sensation revealed through an implanted magnetic prosthetic kinesthetic interface.”**

All data in this repository pertain to **participant MKk-P1**. Scripts are organized to **reproduce the manuscript figures** (main and supplementary) from raw `.mat` files with minimal setup.

---

## Repository structure

├─ Codes/ % Analysis scripts
│ ├─ FINAL_SCRIPT_Analysis_TimeThresholds.m
│ ├─ FINAL_SCRIPT_Analysis_Vividness.m
│ ├─ Likert_DivergingPlot.m
│ ├─ Likert_DivergingPlot_PhaseSplit.m
│ ├─ ParamMap_Waveform.m
│ ├─ ParamMap_SensedHotspots.m
│ ├─ utils/ % helper functions
│ └─ frank-pk-DataViz-3.2.3.0/ % 3rd-party plotting utilities
│
├─ StimulationData/ % Per-site staircase/adaptive sequences
│ ├─ StimulationTimingsSite1.mat
│ └─ ...
│
├─ VividnessData/ % Amplitude & frequency vividness datasets
│ ├─ site1vividData.mat
│ ├─ ...
│ └─ site6vividDataFreq.mat
│
├─ KinestheticData_updateV4.mat % Parameter search data
├─ torqueSensAt90.mat % Torque distribution at 90 Hz
└─ README.md

## Requirements

- **MATLAB** R2023b (earlier versions may work, not fully tested)
- **Toolboxes**
  - *Statistics and Machine Learning Toolbox*
  - *Curve Fitting Toolbox*
- **3rd-party plotting utilities** (bundled)  
  `frank-pk-DataViz-3.2.3.0` for `daboxplot` / `dabarplot`

---

## Quick start

1. Open MATLAB and set the repository root as your current folder.
2. Run the scripts in `Codes/`. Paths to data and utilities are added automatically via `addpath`.

---

## How to reproduce the figures

### 1) Parameter search maps
- **Scripts**: `ParamMap_Waveform.m`, `ParamMap_SensedHotspots.m`  
- **Data**: `KinestheticData_updateV4.mat`  
- **Manuscript**: Fig. 2B (search-space visualization & hot-spot rendering)

### 2) Likert analysis
- **Scripts**: `Likert_DivergingPlot.m`, `Likert_DivergingPlot_PhaseSplit.m`  
- **Manuscript**: Fig. 4 (localization/specificity Likert questions)

### 3) Time thresholds
- **Script**: `FINAL_SCRIPT_Analysis_TimeThresholds.m`  
- **Data**: `StimulationData/*.mat`  
- **Manuscript**: Fig. 5A–B; Fig. S5

### 4) Vividness (amplitude & frequency)
- **Script**: `FINAL_SCRIPT_Analysis_Vividness.m`  
- **Data**: `VividnessData/*.mat`, `torqueSensAt90.mat`  
- **Manuscript**: Fig. 5C–D; Fig. S6

---

## Script–figure cheat sheet

| Script                                  | Data source(s)                      | Manuscript figure(s)           |
|-----------------------------------------|-------------------------------------|--------------------------------|
| `ParamMap_Waveform.m`                   | `KinestheticData_updateV4.mat`      | Fig. 2B                        |
| `ParamMap_SensedHotspots.m`             | `KinestheticData_updateV4.mat`      | Fig. 2B                        |
| `Likert_DivergingPlot*.m`               | embedded Qs                         | Fig. 4                         |
| `FINAL_SCRIPT_Analysis_TimeThresholds.m`| `StimulationData/*.mat`             | Fig. 5A–B; Fig. S5             |
| `FINAL_SCRIPT_Analysis_Vividness.m`     | `VividnessData/*.mat`, torque file  | Fig. 5C–D; Fig. S6             |


---

## Data use

- All datasets are **de-identified** and pertain to **participant MKk-P1**.  
- Research-only, non-commercial use unless otherwise agreed with the authors.

---

## Citation

If you use this code or data, please cite the manuscript:

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

---