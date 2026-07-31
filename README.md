
       # Rainout Shelter Maize Physiology Dataset

This repository contains field and laboratory datasets collected during the 2026 maize rainout-shelter experiment. 

The main datasets were generated using:
- LI-600 Porometer/Fluorometer
- LI-6800 Portable Photosynthesis System
- MultiSpeQ
- Dynamic-light-response measurements

The experiment included:
- 27 field plots
- 3 replications
- 3 intended moisture zones
- 3 maize hybrids
- Up to 12 plants per plot

The expected maximum number of uniquely barcoded plants was 324.

---

# 1. LI-600 Data

| File | Rows | Columns | Unique plants | Plots represented |

|`DATA_DUMP_1782759012237.csv` | 2,849 | 378 | 262 | 27 |
| `DATA_DUMP_1784213332450.csv` | 3,766 | 257 | 253 | 27 |
| `DATA_DUMP_1785116825020.xlsx_suraz_LI600.xlsx` | 11,604 | 257 | 265 | 27 |
| `LI600_Rain_out_All_Data_New.csv` | 5,597 | 261 | 265 | 27 |
| `Data Collection.xlsx` | 16,734 across 7 sheets | up to 378 | 257 | 27 |

These files contain overlapping or cumulative exports. They should not be stacked directly without duplicate removal.

Recommended duplicate key:

```text
Barcode + Date + Time + gsw + PhiPS2 + ETR          
                   
              
              File                   UniquePlants    PlotsRepresented   
    _________________________________    ____________    ________________  

    "DATA_DUMP_1782759012237.csv"            262                27           
    "DATA_DUMP_1784213332450.csv"            253                27          
    "LI600_Rain_out_All_Data_New.csv"        265                27          



          File                                      FileType    SheetCount    Rows     Columns    UniquePlants    PlotsRepresented             
"DATA_DUMP_1781531064037.csv"                      ".csv"           1          245      378            0                 0
06-12 

"DATA_DUMP_1782135968065.csv"                      ".csv"           1         1119      378            0                 0                  
06-12, 06-15, 06-16, 06-17, 06-18, 06-19, 06-20                                                                                  field data before barcode setup in each plant

"DATA_DUMP_1782759012237.csv"                      ".csv"           1         2849      378          262                27  
6-12, 06-15, 06-16, 06-17, 06-18, 06-19, 06-20, 06-23, 06-24, 06-26, 06-27, 06-28   

"DATA_DUMP_1783863517464.csv"                      ".csv"           1         1009      257           16                 4   
"2026-07-08, 2026-07-09, 2026-07-11"   

"DATA_DUMP_1784213332450.csv"                      ".csv"           1         3766      257          253                27
"2026-07-08, 2026-07-09, 2026-07-11, 2026-07-12, 2026-07-13, 2026-07-14"

"DATA_DUMP_1785116825020.xlsx_suraz_LI600.xlsx"    ".xlsx"          1        11604      257          265                27 
******"2026-07-08, 2026-07-09, 2026-07-11, 2026-07-12, 2026-07-13, 2026-07-14**    


***Daily Data Cleaned**
"DATA_DUMP_1785116825020_clean_2026-07-19.csv"     ".csv"           1           33      124            2                 2 
"DATA_DUMP_1785116825020_clean_2026-07-20.csv"     ".csv"           1          232      124            3                 3
"DATA_DUMP_1785116825020_clean_2026-07-21.csv"     ".csv"           1          189      124            9                 8 
"DATA_DUMP_1785116825020_clean_2026-07-22.csv"     ".csv"           1          171      124           12                11
"DATA_DUMP_1785116825020_clean_2026-07-25.csv"     ".csv"           1          104      124            2                 2  
 "DATA_DUMP_1785116825020_clean_2026-07-26.csv"     ".csv"           1           78      124            2                 2  

 **Raw**
"Data Collection.xlsx"                             ".xlsx"          7        16734      378          257                27
"2026-06-12, 2026-06-15, 2026-06-16, 2026-06-17, 2026-06-18, 2026-06-19, 2026-06-20, 2026-06-23, 2026-06-24, 2026-06-26, 2026-06-27, 2026-06-28, 2026-06-30, 2026-07-01, 2026-07-02, 2026-07-03, 2026-07-06, 2026-07-07, 2026-07-08, 2026-07-09, 2026-07-11" 


"LI600_Rain_out_All_Data_New.csv"                  ".csv"           1         5597      261          265                27  
*TO UPDATE*


## 2. LI6800 Data 
"Pretasseling.xlsx"                                ".xlsx"         11          176      296            0                 0  
"Tassel_Data.xlsx"                                 ".xlsx"         14          206      296            0                 0 
"Blister.xlsx"                                     ".xlsx"         11          158      296            0                 0 
"Milk_stage_data.xlsx"                             ".xlsx"          6           87      296            0                 0

"Saturation_check.xlsx"                            ".xlsx"          2           40      296            0                 0  

 Pre-tassel
Sheets: 11
Sheet names: 7_3_Plt23_R3_M3_H2_P3_BT, 7_3_Plt_17_R2_M1_H1_P4_BT, 7_3_Plt7_R1_M2_H1_P8_BT, 7_2_Plt1_R1_M2_H3_P12_BT, 7_2_Plt10_R2_M3_H3_P11_BT, 7_2_Plt19_R3_M1_H1_P2_BT, 7_1_Plt__R3_M3_H2_P7_BT, 7_1_Plt16_R2_M1_H2_P8_BT, 7_1_Plt8_R1_M2_H3_P2_BT, 6_30_Plt_15_R2_M2_H1_5, 6_30_Plt_16_M1_P8_H2_P8

Tassel Data: 14
Sheet names: 7_13_Plt5_R1_M1_H1_P11_Tsl, 7_13_Plt24_R3_M3_H3_P2_Tsl, 7_12_Plt15_R2_M2_H1_P5_Tsl, 7_12_Plt23_R3_M3_H2_P3_Tsl, 7_12_Plt19_R3_H1_M1_P2_Tsl, 7_10_Plt10_R2_M3_H3_P12_Tsl, 7_10_Plt6_R1_M1_H2_P8_Tsl, 7_10_Plt16_R2_M1_H2_P8_Tsl, 7_8_Plt24_R3_M3_H3_P2_Tsl, 7_8_Plt10_R2_M3_H3_P11_Tsl, 7_8_Plt1_R1_M2_H3_P1_Tsl, 7_7_Plt1_R1_M2_H3_P12_Tsl, 7_7_Plt6_R1_M1_H2_P8_Tsl, 7_7_Plt8_R1_M2_H3_P2_Tsl

Blister
Sheets: 11
Sheet names:  7_20_Plt17_R2_M1_H1_P4_Blister, 7_20_Plt10_R2_M3_H3_P10_Blister, 7_20_Plt1_R1_M2_H3_P11_Blister, 7_19_Plt6_R1_M1_H2_P8_Blister, 7_19_Plt8_R1_M2_H3_P2_Blister, 7_19_Plt7_R1_m2_H1_P9_Blister, 7_21_Plt15_R2_M2_H1_P5_Blister, 7_21_Plt16_R2_M1_H2_P8_Blister, 7_22_Plt19_R3_H1_M1_P7_Blister, 7_22_Plt27_R3_M3_H1_P02_Blister, 7_22_Plt24_R3_M3_H3_P1_Blister
  
Milk Stage
Sheets:   6
Sheet names: 7-25-Plt7-P11, 7-25-Plt16-P08, 7-25_plt19_P2, 7-27-Plt1-P10, 7-28_Plt23_7, 7-28_Plt27_P2
 
Saturation Check
7-2_Saturation_P1_11, 7_2_Saturation_Plt27_P3


*Dyanamic Light Data* non-steady light intensity 
"2026-07-23-0940_light-dynamics (2).xlsx"          ".xlsx"          2          121      296            0                 0 


***Data for both Li600 and Li-6800***
7_20_Plt10_R2_M3_H3_P10_Blister
7_21_Plt15_R2_M2_H1_P5_Blister
7_21_Plt16_R2_M1_H2_P8_Blister
7_20_Plt17_R2_M1_H1_P4_Blister
7_22_Plt27_R3_M3_H1_P02_Blister (must be Incorrectly written P03 in li600 since barcode missed for P02)
7_20_Plt17_R2_M1_H1_P4_Blister

Data file
LI600_PlantDays_30Plus.xlsx
Includes plants having more than 30 data points per day




