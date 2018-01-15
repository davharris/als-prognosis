library(tidyverse)

# [1] "AdverseEvents.csv" "alsfrs.csv"        "AlsHistory.csv"    "ConMeds.csv"      
# [5] "DeathData.csv"     "demographics.csv"  "FamilyHistory.csv" "Fvc.csv"          
# [9] "Labs.csv"          "Riluzole.csv"      "Svc.csv"           "Treatment.csv"    
# [13] "VitalSigns.csv"   

frs = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/alsfrs.csv",
  col_types = cols(
    .default = col_double(),
    subject_id = col_integer(),
    ALSFRS_Delta = col_integer(),
    ALSFRS_R_Total = col_integer(),
    R_1_Dyspnea = col_integer(),
    R_2_Orthopnea = col_integer(),
    R_3_Respiratory_Insufficiency = col_integer(),
    Mode_of_Administration = col_character(),
    ALSFRS_Responded_By = col_character()
  )
)

riluzole = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/Riluzole.csv",
  col_types = cols(
    subject_id = col_integer(),
    Subject_used_Riluzole = col_character(),
    Riluzole_use_Delta = col_integer()
  )
)


labs = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/Labs.csv",
  col_types = cols(
    subject_id = col_integer(),
    Test_Name = col_character(),
    Test_Result = col_character(),
    Test_Unit = col_character(),
    Laboratory_Delta = col_integer()
  )
)

fam = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/FamilyHistory.csv",
  col_types = cols(
    .default = col_integer(),
    Other_Specify = col_character(),
    Family_Hx_of_ALS_Mutation = col_character(),
    Family_Hx_of_ALS_Mutation_Other = col_character(),
    Family_Hx_of_Neuro_Disease = col_character(),
    Cousin__Paternal_ = col_character(),
    Cousin__Maternal_ = col_character(),
    Nephew__Maternal_ = col_character(),
    Nephew__Paternal_ = col_character(),
    Niece__Maternal_ = col_character(),
    Niece__Paternal_ = col_character(),
    Other = col_character(),
    Sibling = col_character(),
    Volunteer = col_character(),
    Family_Hx_of_Neuro_Disease_Other = col_character(),
    Neurological_Disease = col_character(),
    Neurological_Disease_Other = col_character()
  )
)

history = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/AlsHistory.csv",
  col_types = cols(
    subject_id = col_integer(),
    Site_of_Onset___Bulbar = col_integer(),
    Site_of_Onset___Limb = col_integer(),
    Site_of_Onset___Limb_and_Bulbar = col_character(),
    Site_of_Onset___Other = col_character(),
    Site_of_Onset___Other_Specify = col_character(),
    Site_of_Onset___Spine = col_character(),
    Subject_ALS_History_Delta = col_integer(),
    Disease_Duration = col_character(),
    Symptom = col_character(),
    Symptom_Other_Specify = col_character(),
    Location = col_character(),
    Location_Other_Specify = col_character(),
    Site_of_Onset = col_character(),
    Onset_Delta = col_integer(),
    Diagnosis_Delta = col_integer()
  )
)

adverse = read_csv(
  "PRO-ACT/Archive/2016_01_04_ALL_FORMS_CSV/AdverseEvents.csv",
  col_types = cols(
    subject_id = col_integer(),
    Lowest_Level_Term = col_character(),
    Preferred_Term = col_character(),
    High_Level_Term = col_character(),
    High_Level_Group_Term = col_character(),
    System_Organ_Class = col_character(),
    SOC_Abbreviation = col_character(),
    SOC_Code = col_integer(),
    Severity = col_character(),
    Outcome = col_character(),
    Start_Date_Delta = col_integer(),
    End_Date_Delta = col_integer()
  )
)

