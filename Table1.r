##########
#Date: 02/22/2023
#Purpose: 
#### 1) Calculate a modified version of the Charlson Comorbidity Index
#### 2) Determine how baseline characteristics vary by 28-day survival 


##########

#packages
library('tidyverse')
library('psych')
library('gtsummary')
library('flextable')

#dems file
file_dems = 'Data/RACE_dems.csv' 
dems = read.csv(file_dems)

#calculate a modified charlson index based on baseline comorbidities 
#consider only relevant columns to the index
charlson = dems %>% select(studyid, Age, 5:35)

#remove comorbidities measured in RACE, not found in the index score
charlson = charlson %>% select(-Immunosuppression..choice.Chronic.Steroid.Use.,
                               -Immunosuppression..choice.Splenectomy.,
                               -Immunosuppression..choice.Transplant.,
                               -Medical.History..choice.Alcoholism.,
                               -Medical.History..choice.DNR.,
                               -Medical.History..choice.HTN.,
                               -Medical.History..choice.Prosthetic.Valve.,
                               -Medical.History..choice.CAD., 
                               -Indwelling.Catheter..choice.Urinary.,
                               -Indwelling.Catheter..choice.Vascular., 
                               -Immunosuppression..choice.HIV.AIDS.)


#mutate RACE comorbidities measured to fit the index
charlson = charlson %>% mutate(Diabetes = Diabetes..choice.ID. + Diabetes..choice.NID.,
                               Renal = Renal.Disease..choice.CRI. + 
                                 Renal.Disease..choice.ESRD. + 
                                 Renal.Disease..choice.CONNECTIVE.TISSUE. +
                                 Renal.Disease..choice.CT.Disease., 
                               Lymphoma = Immunosuppression..choice.Hodgkins.Lymphoma. +
                                 Immunosuppression..choice.NHL.)

#sanity check for mutations above
max(charlson$Diabetes) #equal to 1. shows that no patients are postiive for ID and NID DM
max(charlson$Renal) #equal to 1. shows that no patients have multiple postivies for Renal diseaes
max(charlson$Lymphoma) #equal to 1. shows no patients have both HL and NHL

#remove the old columns which have been mutated to fit index
charlson = charlson %>% select(-starts_with("Renal.Disease.."),
                               -starts_with("Diabetes.."),
                               -Immunosuppression..choice.Hodgkins.Lymphoma.,
                               -Immunosuppression..choice.NHL.)

#score age according to charlson
charlson = charlson %>% mutate(age_score = case_when(
  Age <50 ~ 0, 
  Age <= 59 ~ 1, 
  Age <= 69 ~ 2,
  Age <=79 ~ 3,
  Age >= 80 ~ 4
))

#calculate the charlson score
charlson = charlson %>% mutate(index_score = age_score + 
                                 Medical.History..choice.CHF. + 
                                 Medical.History..choice.COPD. + 
                                 Medical.History..choice.CVA.TIA. + 
                                 Medical.History..choice.Dementia. + 
                                 Medical.History..choice.MI. + 
                                 Medical.History..choice.PVD. + 
                                 Diabetes + 
                                 Liver.Disease..choice.Mild. +
                                 Medical.History..choice.Hemiplegia. * 2 +
                                 Renal * 2 +
                                 Immunosuppression..choice.Leukemia. *2 + 
                                 Lymphoma * 2 + 
                                 Liver.Disease..choice.Cirrhosis. * 3 + 
                                 if_else(Immunosuppression..choice.Metastatic.Disease. == 1,
                                         Immunosuppression..choice.Metastatic.Disease. * 6,
                                         Immunosuppression..choice.Malignancy. * 2)
                               
)

#SOFAs with neuro removed
SOFAfile = "Data/RACE_DetailedT0SOFA.csv"
SOFA = read.csv(SOFAfile)

#Combine the Charlson with the original demographic file
dems_update = dems %>% 
  inner_join(charlson %>% select(studyid, index_score), by = 'studyid') %>%
  inner_join(SOFA %>% select(studyid, T0_NeuroRemoved), by = 'studyid')

#select only the placebo patients 
dems_update %>% mutate(
  Mortality28 = case_when(
    Days.surviving <= 28 ~ 1,
    Days.surviving >28 ~0)) %>% 
  filter(L.carnitine.Dose == 0) -> df_Table1


#some patients from the trial did not have blood samples & metabolomics data available 
#load in this data so it can be determined 
master_file = 'Data/RACE_combined.csv'
df_master = read.csv(master_file)
df_master %>% 
  filter(dose == 0 & (ACstatus == 1 | NMRstatus == 1)) %>% 
  distinct(studyid, .keep_all = TRUE) -> test

df_Table1 %>% filter(`studyid` %in% test$studyid) -> df_Table1
table(df_Table1$Mortality28)

#create flextabl of Table 1
df_Table1$index_score = as.numeric(df_Table1$index_score)
df_Table1$Race = ifelse(df_Table1$Race. == "African American",
                        yes = "African American", no = 'Other')
df_Table1 %>% dplyr::select(Mortality28, Age, Gender., Race,
                        Calculated.T0.SOFA.Value, index_score,
                        Lactate.Value., Cr.Value., Platelets.Value.,
                        Bili.Value., WBC.Value.,
                        BMI., RR, HR., Calculated.CVI.Value.) %>%
  rename(
    
    'Total SOFA Score' = Calculated.T0.SOFA.Value, 
    'Sex' = Gender.,
    'Charlson Comorbidity Index' = index_score, 
    'Clinical Lactate' =  Lactate.Value.,
    'Creatinine' = Cr.Value.,
    'Platelet Count' = Platelets.Value., 
    'Total Bilirubin' = Bili.Value.,
    'White Blood Cell Count' = WBC.Value.,
    'Body Mass Index' = BMI.,
    'Cumulative Vasopressor Index' = Calculated.CVI.Value.,
    'Heart Rate' = HR.,
    'Respiratory Rate' = RR
    
    ) %>% 
  tbl_summary(by = Mortality28,
              type = list(`Charlson Comorbidity Index` ~ 'continuous')) %>%
  add_p(list(all_continuous() ~ "aov",
             'Charlson Comorbidity Index' ~ "aov")) %>% as_flex_table() %>% 
  bold(bold = TRUE, part = 'header') %>%
  autofit() -> ft1

tf <- tempfile(fileext = ".docx")
save_as_docx(ft1, path = tf)

