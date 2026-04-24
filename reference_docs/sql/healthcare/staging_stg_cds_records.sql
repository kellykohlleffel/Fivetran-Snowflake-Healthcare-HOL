
  create or replace   view HOL_DATABASE_2.healthcare_staging.stg_cds_records
  
    
    
(
  
    "RECORD_ID" COMMENT $$$$, 
  
    "PATIENT_ID" COMMENT $$$$, 
  
    "DIAGNOSIS" COMMENT $$$$, 
  
    "MEDICAL_CONDITIONS" COMMENT $$$$, 
  
    "MEDICAL_HISTORY" COMMENT $$$$, 
  
    "FAMILY_MEDICAL_HISTORY" COMMENT $$$$, 
  
    "ALLERGIES" COMMENT $$$$, 
  
    "VITAL_SIGNS" COMMENT $$$$, 
  
    "GENETIC_DATA" COMMENT $$$$, 
  
    "LAB_RESULTS" COMMENT $$$$, 
  
    "CURRENT_MEDICATIONS" COMMENT $$$$, 
  
    "MEDICATION_ADHERENCE" COMMENT $$$$, 
  
    "MEDICATION_RECOMMENDATION" COMMENT $$$$, 
  
    "MEDICATION_SIDE_EFFECTS" COMMENT $$$$, 
  
    "TREATMENT_PLAN" COMMENT $$$$, 
  
    "TREATMENT_RECOMMENDATION" COMMENT $$$$, 
  
    "TREATMENT_OUTCOME" COMMENT $$$$, 
  
    "PATIENT_SATISFACTION" COMMENT $$$$, 
  
    "READMISSION_RISK" COMMENT $$$$, 
  
    "PATIENT_OUTCOME_SCORE" COMMENT $$$$, 
  
    "COST_OF_CARE" COMMENT $$$$, 
  
    "MEDICATION_COST" COMMENT $$$$, 
  
    "TOTAL_COST_SAVINGS" COMMENT $$$$, 
  
    "MEDICAL_ERROR_RATE" COMMENT $$$$, 
  
    "LENGTH_OF_STAY" COMMENT $$$$, 
  
    "CLINICAL_TRIAL_ID" COMMENT $$$$, 
  
    "TRIAL_NAME" COMMENT $$$$, 
  
    "TRIAL_STATUS" COMMENT $$$$, 
  
    "MEDICAL_PUBLICATION_ID" COMMENT $$$$, 
  
    "PUBLICATION_TITLE" COMMENT $$$$, 
  
    "PUBLICATION_DATE" COMMENT $$$$
  
)

  
  
  
  as (
    

with source as (

  select * from HOL_DATABASE_2.HOL_HEALTHCARE.CDS_RECORDS

),

cleaned as (

  select
    record_id,
    patient_id,
    diagnosis,
    medical_conditions,
    medical_history,
    family_medical_history,
    allergies,
    vital_signs,
    genetic_data,
    lab_results,
    current_medications,
    medication_adherence,
    medication_recommendation,
    medication_side_effects,
    treatment_plan,
    treatment_recommendation,
    treatment_outcome,
    patient_satisfaction,
    round(readmission_risk, 4) as readmission_risk,
    round(patient_outcome_score, 4) as patient_outcome_score,
    round(cost_of_care, 2) as cost_of_care,
    round(medication_cost, 2) as medication_cost,
    round(total_cost_savings, 2) as total_cost_savings,
    round(medical_error_rate, 4) as medical_error_rate,
    length_of_stay,
    clinical_trial_id,
    trial_name,
    trial_status,
    medical_publication_id,
    publication_title,
    cast(publication_date as date) as publication_date
  from source

)

select * from cleaned
  );

