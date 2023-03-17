# Pertubed-Host-Metabolism-Metabolic-Clustering-in-Septic-Shock

## **Sustained perturbation of metabolism and metabolic subphenotypes are associated with mortality and protein markers of the host response**

The purpose of this repository is to provide public access to the metabolomics and cytokine data and the R code for the following publication: 

Jennaro TS, Puskarich MA,  Evans CR, Karnovsky A, Flott TL, McLellan LA, Jones AE, Stringer KA. Sustained perturbation of metabolism and metabolic subphenotypes are associated with mortality and protein markers of the host response. Critical Care Explorations. 2023.

#### **Description of files included in the analysis:**

1. Metabolomics and demographic data

* *RACE_combined.csvv* — patient demographic and metabolomics data 
* *RACE_CytokineData.csv* — concentration data of cytokines and chemokines
* *RACE_Dems.csv* — important patient demographic data 
* *RACE_DetailedT0SOFA.csv* - breakdown of baseline (T0) SOFA score by organ system
* *Sample_MetaData.csv* - metadata regarding the cytokine samples 

2. R code 

* *Placebo_LMM.rmd* — R notebook which cleans data and conducts linear mixed modeling for metabolic and protein biomarkers measured  
* *Cytokine_MetaboliteCorrPlot.rmd* - R notebook which explores the repeated measure correlation between metabolites and proteins biomarkers measured 
* *Clustering.rmd* - R notebook which conducts K-means clustering of baseline metabolic data and considers patient characteristics by assigned cluster
* *Table1.r* - R script which creates Table 1 of patient characteristics for the manuscript 


#### **External Links:**

* Link to published manuscript: *pending*

* Link to parent clinical trial (RACE): https://jamanetwork-com.proxy.lib.umich.edu/journals/jamanetworkopen/fullarticle/2719132

* Link to metabolomics spectra: https://www.metabolomicsworkbench.org/data/DRCCMetadata.php?Mode=Study&StudyID=ST001319&StudyType=NMR&ResultType=1
