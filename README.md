# Rainout Shelter Maize Physiology Dataset

## Overview

This repository contains datasets, MATLAB scripts, and manuscript drafts generated during the **2026 maize rainout shelter experiment** conducted at **Kansas State University**. 
The experiment evaluated maize physiological responses to contrasting irrigation treatments using portable photosynthesis, porometry, chlorophyll fluorescence, mutlispeq and soil moisture sensors.

### Instruments Used

- **LI-600** Porometer/Fluorometer
- **LI-6800** Portable Photosynthesis System
- **Campbell Scientific CS655** Soil Moisture Sensors

---

# Repository Structure

```text
Rainout_Shelter/
│
├── README.md
├── LI600/
│   ├── Instrument Exports
│   ├── Daily Cleaned Datasets
│   ├── Combined Dataset
│   ├── Raw Archive
│   └── Excel Export
│
├── LI6800/
│   ├── Pretasseling
│   ├── Tasseling
│   ├── Blister
│   ├── Milk Stage
│   ├── Saturation Check
│   └── Dynamic Light
│
├── Validation/
│
├── Soil_Moisture/
│
├── MATLAB/
│
└── Drafts/
```

---

# Experimental Design

| Parameter | Description |
|:----------|:------------|
| **Crop** | Maize (*Zea mays* L.) |
| **Location** | Kansas State University Rainout Shelter |
| **Experimental Design** | Split-plot randomized complete block design |
| **Replications** | 3 |
| **Irrigation Treatments** | 100%, 75%, and 50% ET |
| **Commercial Hybrids** | 3 |
| **Experimental Plots** | 27 |
| **Maximum Barcoded Plants** | 324 |
| **Instruments** | LI-600, LI-6800, and CS655 |

---

# Repository Contents

| Folder | Files | Description |
|:-------|------:|:------------|
| **LI600** | 12 | Porometer and chlorophyll fluorescence datasets |
| **LI6800** | 6 | Gas exchange and light-response (A–Q) datasets |
| **Validation** | 2 | Paired LI-600 and LI-6800 measurements for instrument comparison |
| **Soil_Moisture** | 2 | Campbell Scientific CS655 soil moisture datasets |
| **MATLAB** | Multiple | MATLAB scripts for data processing, statistical analysis, visualization, and irrigation scheduling |
| **Drafts** | 1 | Manuscript drafts and supporting documents |

---

# 1. LI-600 Dataset

The **LI-600** folder contains porometer and chlorophyll fluorescence measurements collected throughout the 2026 field experiment. The datasets include original instrument exports, cleaned daily files, Excel exports, and a combined analysis-ready dataset.

## Dataset Organization

| Category | Description |
|:---------|:------------|
| **Instrument Exports** | Original data exported directly from the LI-600 instrument |
| **Daily Cleaned Datasets** | Quality-controlled datasets separated by sampling date |
| **Excel Export** | Spreadsheet version of the complete dataset |
| **Raw Archive** | Original field collection workbook containing all sheets |
| **Combined Dataset** | Final merged dataset prepared for statistical analyses |

> **Important**
>
> LI-600 instrument exports are **cumulative** and contain overlapping observations. These files **should not be merged directly** without removing duplicate records.

### Recommended Duplicate Key

```text
Barcode + Date + Time + gsw + PhiPS2 + ETR
```

These files contain overlapping or cumulative exports. They should not be stacked directly without duplicate removal.

## Variables Included for Daily Full Plot Analysis (LI-600)

Each record contains the following variables:

| Variable | Description |
|:---------|:------------|
| `Barcode` | Unique plant identifier |
| `Date` | Measurement date |
| `Time` | Measurement time |
| `gsw` | Stomatal conductance to water vapor (mol m⁻² s⁻¹) |
| `PhiPS2` | Effective quantum yield of Photosystem II (ΦPSII) |
| `ETR` | Electron transport rate (µmol electrons m⁻² s⁻¹) |

---

## Data Useful for Daily Full Plot Analysis (LI-600)

| File | Unique Plants | Plots Represented |
|:-----|--------------:|------------------:|
| `DATA_DUMP_1782759012237.csv` | 262 | 27 |
| `DATA_DUMP_1784213332450.csv` | 253 | 27 |
| `LI600_Rain_out_All_Data_New.csv` | 265 | 27 |


## Complete LI-600 Dataset Inventory

| File | Format | Sheets | Rows | Columns | Unique Plants | Plots Represented | Measurement Dates | Notes |
|:-----|:------:|------:|-----:|--------:|--------------:|------------------:|:------------------|:------|
| `DATA_DUMP_1781531064037.csv` | CSV | 1 | 245 | 378 | 0 | 0 | 2026-06-12 | Initial field data collected before plant barcodes were implemented. |
| `DATA_DUMP_1782135968065.csv` | CSV | 1 | 1,119 | 378 | 0 | 0 | 2026-06-12, 06-15, 06-16, 06-17, 06-18, 06-19, 06-20 | Field data collected before barcode setup. |
| `DATA_DUMP_1782759012237.csv` | CSV | 1 | 2,849 | 378 | 262 | 27 | 2026-06-12, 06-15, 06-16, 06-17, 06-18, 06-19, 06-20, 06-23, 06-24, 06-26, 06-27, 06-28 | First complete barcode-based dataset covering all experimental plots. |
| `DATA_DUMP_1783863517464.csv` | CSV | 1 | 1,009 | 257 | 16 | 4 | 2026-07-08, 07-09, 07-11 | Partial dataset. |
| `DATA_DUMP_1784213332450.csv` | CSV | 1 | 3,766 | 257 | 253 | 27 | 2026-07-08, 07-09, 07-11, 07-12, 07-13, 07-14 | Complete daily dataset covering all experimental plots. |

---

## Excel Export

| File | Format | Sheets | Rows | Columns | Unique Plants | Plots Represented | Measurement Dates | Notes |
|:-----|:------:|------:|-----:|--------:|--------------:|------------------:|:------------------|:------|
| `DATA_DUMP_1785116825020.xlsx_suraz_LI600.xlsx` | Excel (.xlsx) | 1 | 11,604 | 257 | 265 | 27 | 2026-07-08, 07-09, 07-11, 07-12, 07-13, 07-14 | Excel export of the complete LI-600 dataset for analysis. Contains the same measurements as the July CSV dataset in spreadsheet format. |

## Daily Cleaned LI-600 Datasets

These files contain cleaned observations for individual sampling dates and are intended for day-specific analyses.

| File | Format | Rows | Columns | Unique Plants | Plots Represented |
|:-----|:------:|-----:|--------:|--------------:|------------------:|
| `DATA_DUMP_1785116825020_clean_2026-07-19.csv` | CSV | 33 | 124 | 2 | 2 |
| `DATA_DUMP_1785116825020_clean_2026-07-20.csv` | CSV | 232 | 124 | 3 | 3 |
| `DATA_DUMP_1785116825020_clean_2026-07-21.csv` | CSV | 189 | 124 | 9 | 8 |
| `DATA_DUMP_1785116825020_clean_2026-07-22.csv` | CSV | 171 | 124 | 12 | 11 |
| `DATA_DUMP_1785116825020_clean_2026-07-25.csv` | CSV | 104 | 124 | 2 | 2 |
| `DATA_DUMP_1785116825020_clean_2026-07-26.csv` | CSV | 78 | 124 | 2 | 2 |

---

## Raw LI-600 Dataset

| File | Format | Sheets | Rows | Columns | Unique Plants | Plots Represented | Measurement Dates |
|:-----|:------:|------:|-----:|--------:|--------------:|------------------:|:------------------|
| `Data Collection.xlsx` | Excel (.xlsx) | 7 | 16,734 | 378 | 257 | 27 | 2026-06-12, 06-15, 06-16, 06-17, 06-18, 06-19, 06-20, 06-23, 06-24, 06-26, 06-27, 06-28, 06-30, 07-01, 07-02, 07-03, 07-06, 07-07, 07-08, 07-09, 07-11 |



## Combined Analysis Dataset

This dataset combines all valid barcode-based LI-600 measurements into a single analysis-ready file for whole-experiment analyses.

| File | Format | Rows | Columns | Unique Plants | Plots Represented |
|:-----|:------:|-----:|--------:|--------------:|------------------:|
| `LI600_Rain_out_All_Data_New.csv` | CSV | 5,597 | 261 | 265 | 27 |

**Recommended uses**
- Whole-experiment statistical analyses
- Hybrid × irrigation comparisons
- Plot-level summaries
- Daily physiological response analyses



## 2. LI-6800 Data
## Primary Variables

| Variable | Description |
|:---------|:------------|
| GasEx_A | Net photosynthetic rate |
| GasEx_gsw | Stomatal conductance |
| GasEx_Ci | Intercellular CO₂ concentration |
| LeafQ_Qin | Incident PAR |
| ChlF_PhiPS2 | Effective quantum yield |
| ChlF_ETR | Electron transport rate |
| ChlF_NPQ | Non-photochemical quenching |
| LeafT_Tleaf | Leaf temperature |



### Pretasseling.xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 11
- **Rows:** 176
- **Columns:** 296

**Sheet Names**

- 7_3_Plt23_R3_M3_H2_P3_BT
- 7_3_Plt17_R2_M1_H1_P4_BT
- 7_3_Plt7_R1_M2_H1_P8_BT
- 7_2_Plt1_R1_M2_H3_P12_BT
- 7_2_Plt10_R2_M3_H3_P11_BT
- 7_2_Plt19_R3_M1_H1_P2_BT
- 7_1_Plt_R3_M3_H2_P7_BT
- 7_1_Plt16_R2_M1_H2_P8_BT
- 7_1_Plt8_R1_M2_H3_P2_BT
- 6_30_Plt15_R2_M2_H1_5
- 6_30_Plt16_M1_P8_H2_P8

---

### Tassel_Data.xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 14
- **Rows:** 206
- **Columns:** 296

**Sheet Names**

- 7_13_Plt5_R1_M1_H1_P11_Tsl
- 7_13_Plt24_R3_M3_H3_P2_Tsl
- 7_12_Plt15_R2_M2_H1_P5_Tsl
- 7_12_Plt23_R3_M3_H2_P3_Tsl
- 7_12_Plt19_R3_H1_M1_P2_Tsl
- 7_10_Plt10_R2_M3_H3_P12_Tsl
- 7_10_Plt6_R1_M1_H2_P8_Tsl
- 7_10_Plt16_R2_M1_H2_P8_Tsl
- 7_8_Plt24_R3_M3_H3_P2_Tsl
- 7_8_Plt10_R2_M3_H3_P11_Tsl
- 7_8_Plt1_R1_M2_H3_P1_Tsl
- 7_7_Plt1_R1_M2_H3_P12_Tsl
- 7_7_Plt6_R1_M1_H2_P8_Tsl
- 7_7_Plt8_R1_M2_H3_P2_Tsl

---

### Blister.xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 11
- **Rows:** 158
- **Columns:** 296

**Sheet Names**

- 7_20_Plt17_R2_M1_H1_P4_Blister
- 7_20_Plt10_R2_M3_H3_P10_Blister
- 7_20_Plt1_R1_M2_H3_P11_Blister
- 7_19_Plt6_R1_M1_H2_P8_Blister
- 7_19_Plt8_R1_M2_H3_P2_Blister
- 7_19_Plt7_R1_M2_H1_P9_Blister
- 7_21_Plt15_R2_M2_H1_P5_Blister
- 7_21_Plt16_R2_M1_H2_P8_Blister
- 7_22_Plt19_R3_H1_M1_P7_Blister
- 7_22_Plt27_R3_M3_H1_P02_Blister
- 7_22_Plt24_R3_M3_H3_P1_Blister

---

### Milk_stage_data.xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 6
- **Rows:** 87
- **Columns:** 296

**Sheet Names**

- 7-25-Plt7-P11
- 7-25-Plt16-P08
- 7-25_plt19_P2
- 7-27-Plt1-P10
- 7-28_Plt23_7
- 7-28_Plt27_P2

---

### Saturation_check.xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 2
- **Rows:** 40
- **Columns:** 296

**Sheet Names**

- 7-2_Saturation_P1_11
- 7_2_Saturation_Plt27_P3

---

### 2026-07-23-0940_light-dynamics (2).xlsx

- **Format:** Excel (.xlsx)
- **Sheets:** 2
- **Rows:** 121
- **Columns:** 296

**Sheet Names**

- Light_Dynamics
- Fluorometer




## 3. Paired LI-600 and LI-6800 Validation Dataset

This dataset contains paired measurements collected on the **same maize plants** using both the **LI-600 Porometer/Fluorometer** and the **LI-6800 Portable Photosynthesis System**. These data are intended for direct instrument comparison and validation analyses.

### Paired LI-6800 Measurements

| LI-6800 Sheet |
|:--------------|
| `7_20_Plt10_R2_M3_H3_P10_Blister` |
| `7_21_Plt15_R2_M2_H1_P5_Blister` |
| `7_21_Plt16_R2_M1_H2_P8_Blister` |
| `7_20_Plt17_R2_M1_H1_P4_Blister` |
| `7_22_Plt27_R3_M3_H1_P02_Blister` |



---

### Corresponding LI-600 Dataset

| File | Format | Description |
|:-----|:------:|:------------|
| `LI600_PlantDays_30Plus.xlsx` | Excel (.xlsx) | Contains LI-600 measurements from plants with **30 or more observations per day**, corresponding to the paired LI-6800 measurements used for cross-instrument comparison. |

### Intended Use

- Same-plant LI-600 vs LI-6800 comparison
- Cross-instrument physiological validation
- Estimation of relationships between stomatal conductance, chlorophyll fluorescence, and gas exchange
- Method development and calibration analyses


# 4. Soil Moisture Data

Soil volumetric water content (VWC) was monitored continuously using **Campbell Scientific CS655** soil moisture sensors installed in the experimental field. These datasets were used to verify irrigation treatments and characterize soil water dynamics throughout the growing season.

| File | Format | Description |
|:-----|:------:|:------------|
| `all_starttime_11_36_new_06_30.dat` | Campbell Scientific `.dat` | Complete soil moisture dataset containing measurements from all installed CS655 sensors throughout the monitoring period. |
| `Zone1_M2_starttime_11_23.dat` | Campbell Scientific `.dat` | Soil moisture measurements from the Zone 1 sensor installed in the M2 (75% ET) irrigation treatment. |

### Measured Variables

- Timestamp
- Volumetric Water Content (VWC)
- Soil Temperature
- Electrical Conductivity (EC)
- Sensor diagnostics (if available)

### Intended Use

- Irrigation treatment verification
- Daily soil moisture dynamics
- Water availability analysis
- Environmental covariate for LI-600 and LI-6800 physiological measurements

## 5. Drafts

This folder contains manuscript drafts and supporting documents related to the research project.

| File | Format | Description |
|:-----|:------:|:------------|
| `Methodology_Paper_Draft.docx` | Microsoft Word (.docx) | Working draft of the methodology manuscript describing the experimental design, instrumentation (LI-600 and LI-6800), data processing workflow, validation approach, and planned analyses. |


## 6. MATLAB Codes

This folder contains MATLAB scripts developed for experimental design, data processing, statistical analysis, and irrigation management.

| Script Category | Description |
|:----------------|:------------|
| **Field Layout** | MATLAB scripts used to generate and visualize the experimental field layout, including plot numbering, irrigation treatments, hybrid assignments, and barcode mapping. |
| **ANOVA Analysis** | Scripts for statistical analysis of physiological and agronomic data, including treatment comparisons, factorial ANOVA, post-hoc multiple comparisons, and publication-quality figures. |
| **Irrigation Scheduling** | MATLAB scripts for crop evapotranspiration (ET)-based irrigation scheduling, irrigation amount calculations, and soil moisture balance analyses. |




