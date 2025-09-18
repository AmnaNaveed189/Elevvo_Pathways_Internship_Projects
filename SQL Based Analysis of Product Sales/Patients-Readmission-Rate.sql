Create Database Hospital_Readmission;
Use Hospital_Readmission;

CREATE TABLE diabetes_patients (
    age VARCHAR(20),
    time_in_hospital INT,
    n_procedures INT,
    n_lab_procedures INT,
    n_medications INT,
    n_outpatient INT,
    n_inpatient INT,
    n_emergency INT,
    medical_specialty VARCHAR(255),
    diag_1 VARCHAR(255),
    diag_2 VARCHAR(255),
    diag_3 VARCHAR(255),
    glucose_test VARCHAR(50),
    AICtest VARCHAR(50),
    medication_change VARCHAR(10), -- Renamed from 'change'
    diabetes_med VARCHAR(10),      -- Renamed from 'diabetes_med'
    readmitted VARCHAR(10)
);

Select distinct(diag_1) from diabetes_patients;
Select distinct(medical_specialty) from diabetes_patients;
Select distinct(age) from diabetes_patients;

Select count(*) from diabetes_patients;

Select count(readmitted), age from diabetes_patients
where age = '[50-60)'
AND readmitted = 'Yes' ;

Select count(readmitted), age from diabetes_patients
where age = '[60-70)'
AND readmitted = 'Yes' ;

Select count(readmitted), age from diabetes_patients
where age = '[70-80)'
AND readmitted = 'Yes' ;

Select count(readmitted), age from diabetes_patients
where age = '[80-90)'
AND readmitted = 'Yes' ;
-- Overall Readmission Rate
SELECT 
    readmitted,
    COUNT(*) AS number_of_patients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diabetes_patients), 2) AS percentage
FROM diabetes_patients
GROUP BY readmitted;

-- Readmission Rate by Age Group
SELECT 
    age,
    readmitted,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY age), 2) AS readmission_percentage
FROM diabetes_patients
GROUP BY age, readmitted
ORDER BY age, readmitted;

-- Average Time and Procedures for Readmitted vs. Not Readmitted Patients
Select readmitted,
round(avg(time_in_hospital),2) as avg_time_in_hospital,
round(avg(n_lab_procedures), 2) as avg_lab_procedures,
round(avg(n_procedures), 2) as avg_procedures,
round(avg(n_medications), 2) as avg_medications
from diabetes_patients
Group by readmitted;


-- Compare Prior Visits by Readmission Status
Select readmitted,
round(avg(n_outpatient), 2) as avg_outpatient_visit,
round(avg(n_inpatient), 2) as avg_inpatient_visit,
round(avg(n_emergency), 2) as avg_emergency_visit
from diabetes_patients
Group by readmitted;


WITH DiagnosisStats AS (
    SELECT 
        diag_1,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS readmitted_patients
    FROM diabetes_patients
    WHERE diag_1 IS NOT NULL
    GROUP BY diag_1
    HAVING COUNT(*) > 50 -- Filter out rare diagnoses for significance
)
SELECT 
    diag_1,
    total_patients,
    readmitted_patients,
    ROUND((readmitted_patients * 100.0 / total_patients), 2) AS readmission_rate
FROM DiagnosisStats
ORDER BY readmission_rate DESC
LIMIT 5;

WITH DiagnosisStats AS (
    SELECT 
        diag_2,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS readmitted_patients
    FROM diabetes_patients
    WHERE diag_2 IS NOT NULL
    GROUP BY diag_2
    HAVING COUNT(*) > 50 -- Filter out rare diagnoses for significance
)
SELECT 
    diag_2,
    total_patients,
    readmitted_patients,
    ROUND((readmitted_patients * 100.0 / total_patients), 2) AS readmission_rate
FROM DiagnosisStats
ORDER BY readmission_rate DESC
LIMIT 5;

WITH DiagnosisStats AS (
    SELECT 
        diag_3,
        COUNT(*) AS total_patients,
        SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) AS readmitted_patients
    FROM diabetes_patients
    WHERE diag_3 IS NOT NULL
    GROUP BY diag_3
    HAVING COUNT(*) > 50 -- Filter out rare diagnoses for significance
)
SELECT 
    diag_3,
    total_patients,
    readmitted_patients,
    ROUND((readmitted_patients * 100.0 / total_patients), 2) AS readmission_rate
FROM DiagnosisStats
ORDER BY readmission_rate DESC
LIMIT 5;

-- Readmission Rates by Top Medical Specialties
Select medical_specialty,
count(*) as total_patients,
SUM(CASE when readmitted = 'yes' then 1 else 0 end) as readmitted_patients,
round(sum(case when readmitted = 'yes' then 1 else 0 end)*100.0/count(*), 2) as readmission_rate
from diabetes_patients
where medical_specialty is not null
Group by medical_specialty
having count(*) > 3
Order by readmission_rate DESC
limit 10;

--  Impact of Glucose and A1C Tests on Readmission
SELECT 
    glucose_test,
    AICtest,
    readmitted,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY glucose_test, AICtest), 2) AS readmission_percentage
FROM diabetes_patients
GROUP BY glucose_test, AICtest, readmitted
ORDER BY readmission_percentage DESC;

-- The Critical Interaction: Medication Change and Readmission
SELECT 
    medication_change,
    diabetes_med,
    readmitted,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY medication_change, diabetes_med), 2) AS readmission_percentage
FROM diabetes_patients
WHERE medication_change IN ('yes', 'no') AND diabetes_med IN ('yes', 'no')
GROUP BY medication_change, diabetes_med, readmitted
ORDER BY readmission_percentage DESC;

-- Readmission Rate by Different AGe Groups
Select age,
count(*) as total_patients,
ROUND( (SUM(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS readmission_rate
from diabetes_patients
Group by age
Order by readmission_rate DESC;





