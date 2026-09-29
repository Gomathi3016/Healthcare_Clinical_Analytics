#Validate table row counts
SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM `healthcare-data-analytic.healthcare_data_analysis.patients`

UNION ALL

SELECT 'encounters', COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`

UNION ALL

SELECT 'labs', COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.labs`

UNION ALL

SELECT 'diagnoses', COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.diagnoses`

UNION ALL

SELECT 'medications', COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.medications`

UNION ALL

SELECT 'data_dictionary', COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.data_dictionary`;

#Validate Patient_ID relationships
SELECT
  'encounters → patients' AS relationship,
  COUNT(*) AS orphan_rows
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
LEFT JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
WHERE p.Patient_ID IS NULL

UNION ALL

SELECT
  'labs → patients',
  COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.labs` l
LEFT JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON l.Patient_ID = p.Patient_ID
WHERE p.Patient_ID IS NULL

UNION ALL

SELECT
  'diagnoses → patients',
  COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.diagnoses` d
LEFT JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON d.Patient_ID = p.Patient_ID
WHERE p.Patient_ID IS NULL

UNION ALL

SELECT
  'medications → patients',
  COUNT(*)
FROM `healthcare-data-analytic.healthcare_data_analysis.medications` m
LEFT JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON m.Patient_ID = p.Patient_ID
WHERE p.Patient_ID IS NULL;


#analysing patient population
SELECT
  COUNT(*) AS total_patients,
  ROUND(AVG(Age), 2) AS average_age,
  COUNTIF(Gender = 'Female') AS female_patients,
  COUNTIF(Gender = 'Male') AS male_patients,
  COUNTIF(Risk_Category = 'High') AS high_risk_patients,
  COUNTIF(Risk_Category = 'Medium') AS medium_risk_patients,
  COUNTIF(Risk_Category = 'Low') AS low_risk_patients
FROM `healthcare-data-analytic.healthcare_data_analysis.patients`;

#Patient distribution by primary condition
SELECT
  Primary_Condition,
  COUNT(*) AS patient_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS patient_percentage,
  ROUND(AVG(Age), 1) AS average_age
FROM `healthcare-data-analytic.healthcare_data_analysis.patients`
GROUP BY Primary_Condition
ORDER BY patient_count DESC;

#Analyze healthcare utilization
SELECT
  Encounter_Type,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS encounter_percentage,
  ROUND(AVG(Length_of_Stay_Days), 2) AS average_length_of_stay
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
GROUP BY Encounter_Type
ORDER BY encounter_count DESC;

#Analyze encounter outcomes
SELECT
  Outcome,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS outcome_percentage,
  ROUND(AVG(Length_of_Stay_Days), 2) AS average_length_of_stay
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
GROUP BY Outcome
ORDER BY encounter_count DESC;

#Outcome by encounter type
SELECT
  Encounter_Type,
  Outcome,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNT(*) * 100.0
    / SUM(COUNT(*)) OVER (PARTITION BY Encounter_Type),
    2
  ) AS outcome_percentage
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
GROUP BY Encounter_Type, Outcome
ORDER BY Encounter_Type, encounter_count DESC;


#Healthcare utilization by risk category
SELECT
  p.Risk_Category,
  COUNT(e.Encounter_ID) AS encounter_count,
  COUNT(DISTINCT e.Patient_ID) AS patients_with_encounters,
  ROUND(
    COUNT(e.Encounter_ID) * 1.0
    / COUNT(DISTINCT e.Patient_ID),
    2
  ) AS avg_encounters_per_patient,
  ROUND(AVG(e.Length_of_Stay_Days), 2) AS average_length_of_stay
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
GROUP BY p.Risk_Category
ORDER BY
  CASE p.Risk_Category
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
  END;


#Healthcare utilization by primary condition
SELECT
  p.Primary_Condition,
  COUNT(e.Encounter_ID) AS encounter_count,
  COUNT(DISTINCT e.Patient_ID) AS patients_with_encounters,
  ROUND(
    COUNT(e.Encounter_ID) * 1.0
    / COUNT(DISTINCT e.Patient_ID),
    2
  ) AS avg_encounters_per_patient,
  ROUND(AVG(e.Length_of_Stay_Days), 2) AS average_length_of_stay
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
GROUP BY p.Primary_Condition
ORDER BY avg_encounters_per_patient DESC;

#Laboratory test volume
SELECT
  Test_Name,
  COUNT(*) AS test_count,
  COUNT(Result_Value) AS valid_results,
  COUNTIF(Result_Value IS NULL) AS missing_results,
  ROUND(
    COUNTIF(Result_Value IS NULL) * 100.0 / COUNT(*),
    2
  ) AS missing_percentage,
  ROUND(AVG(Result_Value), 2) AS average_result
FROM `healthcare-data-analytic.healthcare_data_analysis.labs`
GROUP BY Test_Name
ORDER BY test_count DESC;


#Laboratory results by risk category
SELECT
  p.Risk_Category,
  l.Test_Name,
  COUNT(l.Result_Value) AS valid_results,
  ROUND(AVG(l.Result_Value), 2) AS average_result,
  ROUND(MIN(l.Result_Value), 2) AS minimum_result,
  ROUND(MAX(l.Result_Value), 2) AS maximum_result
FROM `healthcare-data-analytic.healthcare_data_analysis.labs` l
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON l.Patient_ID = p.Patient_ID
WHERE l.Result_Value IS NOT NULL
GROUP BY
  p.Risk_Category,
  l.Test_Name
ORDER BY
  CASE p.Risk_Category
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
  END,
  l.Test_Name;


#Diagnosis prevalence
SELECT
  Diagnosis_Name,
  Diagnosis_Code,
  COUNT(*) AS diagnosis_records,
  COUNT(DISTINCT Patient_ID) AS unique_patients,
  ROUND(
    COUNT(DISTINCT Patient_ID) * 100.0
    / (SELECT COUNT(*) FROM `healthcare-data-analytic.healthcare_data_analysis.patients`),
    2
  ) AS patient_percentage
FROM `healthcare-data-analytic.healthcare_data_analysis.diagnoses`
WHERE Diagnosis_Code != 'UNK'
GROUP BY
  Diagnosis_Name,
  Diagnosis_Code
ORDER BY unique_patients DESC;

#Medication utilization
SELECT
  Medication_Name,
  COUNT(*) AS medication_records,
  COUNT(DISTINCT Patient_ID) AS unique_patients,
  ROUND(
    COUNT(DISTINCT Patient_ID) * 100.0
    / (SELECT COUNT(*)
       FROM `healthcare-data-analytic.healthcare_data_analysis.patients`),
    2
  ) AS patient_percentage,
  COUNTIF(Medication_Status = 'Active') AS active_records,
  COUNTIF(Medication_Status = 'Discontinued') AS discontinued_records,
  COUNTIF(Medication_Status = 'Completed') AS completed_records
FROM `healthcare-data-analytic.healthcare_data_analysis.medications`
GROUP BY Medication_Name
ORDER BY unique_patients DESC;

#Medication utilization by primary condition
WITH condition_patients AS (
  SELECT
    Primary_Condition,
    COUNT(DISTINCT Patient_ID) AS total_condition_patients
  FROM `healthcare-data-analytic.healthcare_data_analysis.patients`
  GROUP BY Primary_Condition
),

medication_by_condition AS (
  SELECT
    p.Primary_Condition,
    m.Medication_Name,
    COUNT(*) AS medication_records,
    COUNT(DISTINCT m.Patient_ID) AS unique_patients
  FROM `healthcare-data-analytic.healthcare_data_analysis.medications` m
  JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
    ON m.Patient_ID = p.Patient_ID
  GROUP BY
    p.Primary_Condition,
    m.Medication_Name
)

SELECT
  mbc.Primary_Condition,
  mbc.Medication_Name,
  mbc.medication_records,
  mbc.unique_patients,
  cp.total_condition_patients,
  ROUND(
    mbc.unique_patients * 100.0 / cp.total_condition_patients,
    2
  ) AS condition_patient_percentage
FROM medication_by_condition mbc
JOIN condition_patients cp
  ON mbc.Primary_Condition = cp.Primary_Condition
ORDER BY
  mbc.Primary_Condition,
  mbc.unique_patients DESC;


#Monthly healthcare utilization trend
SELECT
  DATE_TRUNC(Encounter_Date, MONTH) AS month,
  COUNT(*) AS encounter_count,
  COUNTIF(Outcome = 'Improved') AS improved_encounters,
  COUNTIF(Outcome = 'Worsened') AS worsened_encounters,
  COUNTIF(Outcome = 'Referred') AS referred_encounters,
  ROUND(
    COUNTIF(Outcome = 'Improved') * 100.0 / COUNT(*),
    2
  ) AS improvement_rate,
  ROUND(
    COUNTIF(Outcome = 'Worsened') * 100.0 / COUNT(*),
    2
  ) AS worsening_rate
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
GROUP BY month
ORDER BY month;

#Outcomes by clinical risk category
SELECT
  p.Risk_Category,
  e.Outcome,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNT(*) * 100.0
    / SUM(COUNT(*)) OVER (PARTITION BY p.Risk_Category),
    2
  ) AS outcome_percentage
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
GROUP BY
  p.Risk_Category,
  e.Outcome
ORDER BY
  CASE p.Risk_Category
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
  END,
  encounter_count DESC;




##Clinical data quality check
SELECT
  'patients' AS table_name,
  COUNTIF(Gender = 'Unknown') AS invalid_gender_values,
  COUNTIF(Patient_ID IS NULL) AS missing_patient_id
FROM `healthcare-data-analytic.healthcare_data_analysis.patients`

UNION ALL

SELECT
  'encounters',
  COUNTIF(Outcome = 'Unknown'),
  COUNTIF(Patient_ID IS NULL)
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`

UNION ALL

SELECT
  'labs',
  COUNTIF(Result_Value IS NULL),
  COUNTIF(Patient_ID IS NULL)
FROM `healthcare-data-analytic.healthcare_data_analysis.labs`

UNION ALL

SELECT
  'diagnoses',
  COUNTIF(Diagnosis_Code = 'UNK'),
  COUNTIF(Patient_ID IS NULL)
FROM `healthcare-data-analytic.healthcare_data_analysis.diagnoses`

UNION ALL

SELECT
  'medications',
  0,
  COUNTIF(Patient_ID IS NULL)
FROM `healthcare-data-analytic.healthcare_data_analysis.medications`;


#Patient encounter utilization distribution
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  encounter_count,
  COUNT(*) AS patient_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS patient_percentage
FROM patient_utilization
GROUP BY encounter_count
ORDER BY encounter_count;


#Identify high-utilization patients
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count,
    COUNTIF(Encounter_Type = 'Emergency') AS emergency_encounters,
    COUNTIF(Encounter_Type = 'Inpatient') AS inpatient_encounters,
    ROUND(AVG(Length_of_Stay_Days), 2) AS average_length_of_stay
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  p.Patient_ID,
  p.Age,
  p.Gender,
  p.Risk_Category,
  p.Primary_Condition,
  p.Region,
  pu.encounter_count,
  pu.emergency_encounters,
  pu.inpatient_encounters,
  pu.average_length_of_stay
FROM patient_utilization pu
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON pu.Patient_ID = p.Patient_ID
WHERE pu.encounter_count >= 6
ORDER BY pu.encounter_count DESC, pu.emergency_encounters DESC;


#Profile high-utilization patients
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
),

high_utilization AS (
  SELECT
    Patient_ID
  FROM patient_utilization
  WHERE encounter_count >= 6
)

SELECT
  p.Risk_Category,
  p.Primary_Condition,
  p.Region,
  COUNT(*) AS high_utilization_patients,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (),
    2
  ) AS segment_percentage
FROM high_utilization h
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON h.Patient_ID = p.Patient_ID
GROUP BY
  p.Risk_Category,
  p.Primary_Condition,
  p.Region
ORDER BY high_utilization_patients DESC;

#High-utilization rate by risk category
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  p.Risk_Category,
  COUNT(*) AS total_patients,
  COUNTIF(pu.encounter_count >= 6) AS high_utilization_patients,
  ROUND(
    COUNTIF(pu.encounter_count >= 6) * 100.0 / COUNT(*),
    2
  ) AS high_utilization_rate
FROM `healthcare-data-analytic.healthcare_data_analysis.patients` p
LEFT JOIN patient_utilization pu
  ON p.Patient_ID = pu.Patient_ID
GROUP BY p.Risk_Category
ORDER BY
  CASE p.Risk_Category
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
  END;

#High-utilization rate by primary condition
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  p.Primary_Condition,
  COUNT(*) AS total_patients,
  COUNTIF(pu.encounter_count >= 6) AS high_utilization_patients,
  ROUND(
    COUNTIF(pu.encounter_count >= 6) * 100.0 / COUNT(*),
    2
  ) AS high_utilization_rate
FROM `healthcare-data-analytic.healthcare_data_analysis.patients` p
LEFT JOIN patient_utilization pu
  ON p.Patient_ID = pu.Patient_ID
GROUP BY p.Primary_Condition
ORDER BY high_utilization_rate DESC;

#Emergency and inpatient utilization among high-utilization patients
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count,
    COUNTIF(Encounter_Type = 'Emergency') AS emergency_encounters,
    COUNTIF(Encounter_Type = 'Inpatient') AS inpatient_encounters
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  COUNT(*) AS high_utilization_patients,
  ROUND(AVG(encounter_count), 2) AS avg_encounters_per_patient,
  ROUND(AVG(emergency_encounters), 2) AS avg_emergency_encounters,
  ROUND(AVG(inpatient_encounters), 2) AS avg_inpatient_encounters,
  COUNTIF(emergency_encounters > 0) AS patients_with_emergency_visits,
  COUNTIF(inpatient_encounters > 0) AS patients_with_inpatient_visits
FROM patient_utilization
WHERE encounter_count >= 6;


#Diagnosis burden per patient
WITH patient_diagnoses AS (
  SELECT
    Patient_ID,
    COUNT(DISTINCT Diagnosis_Code) AS distinct_diagnoses
  FROM `healthcare-data-analytic.healthcare_data_analysis.diagnoses`
  WHERE Diagnosis_Code != 'UNK'
  GROUP BY Patient_ID
)

SELECT
  distinct_diagnoses,
  COUNT(*) AS patient_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS patient_percentage
FROM patient_diagnoses
GROUP BY distinct_diagnoses
ORDER BY distinct_diagnoses;


#High utilization vs encounter outcomes
WITH patient_utilization AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
),

classified_encounters AS (
  SELECT
    e.Outcome,
    CASE
      WHEN pu.encounter_count >= 6 THEN 'High Utilization'
      ELSE 'Standard Utilization'
    END AS utilization_group
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
  JOIN patient_utilization pu
    ON e.Patient_ID = pu.Patient_ID
)

SELECT
  utilization_group,
  Outcome,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNT(*) * 100.0
    / SUM(COUNT(*)) OVER (PARTITION BY utilization_group),
    2
  ) AS outcome_percentage
FROM classified_encounters
GROUP BY
  utilization_group,
  Outcome
ORDER BY
  utilization_group,
  encounter_count DESC;

#Regional healthcare utilization
SELECT
  p.Region,
  COUNT(e.Encounter_ID) AS encounter_count,
  COUNT(DISTINCT e.Patient_ID) AS patients_served,
  ROUND(
    COUNT(e.Encounter_ID) * 1.0
    / COUNT(DISTINCT e.Patient_ID),
    2
  ) AS avg_encounters_per_patient,
  COUNTIF(e.Encounter_Type = 'Emergency') AS emergency_encounters,
  COUNTIF(e.Encounter_Type = 'Inpatient') AS inpatient_encounters,
  ROUND(AVG(e.Length_of_Stay_Days), 2) AS average_length_of_stay
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
GROUP BY p.Region
ORDER BY avg_encounters_per_patient DESC;

#Regional outcomes
SELECT
  p.Region,
  COUNT(*) AS encounter_count,
  ROUND(
    COUNTIF(e.Outcome = 'Improved') * 100.0 / COUNT(*),
    2
  ) AS improvement_rate,
  ROUND(
    COUNTIF(e.Outcome = 'Stable') * 100.0 / COUNT(*),
    2
  ) AS stable_rate,
  ROUND(
    COUNTIF(e.Outcome = 'Referred') * 100.0 / COUNT(*),
    2
  ) AS referral_rate,
  ROUND(
    COUNTIF(e.Outcome = 'Worsened') * 100.0 / COUNT(*),
    2
  ) AS worsening_rate
FROM `healthcare-data-analytic.healthcare_data_analysis.encounter` e
JOIN `healthcare-data-analytic.healthcare_data_analysis.patients` p
  ON e.Patient_ID = p.Patient_ID
GROUP BY p.Region
ORDER BY improvement_rate DESC;

#Laboratory distributions and statistical outliers
WITH lab_stats AS (
  SELECT
    Test_Name,
    COUNT(Result_Value) AS valid_results,
    ROUND(AVG(Result_Value), 2) AS average_result,
    ROUND(STDDEV(Result_Value), 2) AS standard_deviation,
    ROUND(APPROX_QUANTILES(Result_Value, 4)[OFFSET(1)], 2) AS Q1,
    ROUND(APPROX_QUANTILES(Result_Value, 4)[OFFSET(2)], 2) AS median,
    ROUND(APPROX_QUANTILES(Result_Value, 4)[OFFSET(3)], 2) AS Q3
  FROM `healthcare-data-analytic.healthcare_data_analysis.labs`
  WHERE Result_Value IS NOT NULL
  GROUP BY Test_Name
)

SELECT
  Test_Name,
  valid_results,
  average_result,
  standard_deviation,
  Q1,
  median,
  Q3,
  ROUND(Q3 - Q1, 2) AS IQR,
  ROUND(Q1 - 1.5 * (Q3 - Q1), 2) AS lower_outlier_bound,
  ROUND(Q3 + 1.5 * (Q3 - Q1), 2) AS upper_outlier_bound
FROM lab_stats
ORDER BY Test_Name;


#Final integrated patient analysis
WITH patient_encounters AS (
  SELECT
    Patient_ID,
    COUNT(*) AS encounter_count,
    COUNTIF(Encounter_Type = 'Emergency') AS emergency_encounters,
    COUNTIF(Encounter_Type = 'Inpatient') AS inpatient_encounters,
    COUNTIF(Outcome = 'Worsened') AS worsened_encounters,
    COUNT(*) AS total_outcomes
  FROM `healthcare-data-analytic.healthcare_data_analysis.encounter`
  GROUP BY Patient_ID
)

SELECT
  p.Risk_Category,
  p.Primary_Condition,
  COUNT(*) AS total_patients,

  COUNTIF(
    COALESCE(pe.encounter_count, 0) >= 6
  ) AS high_utilization_patients,

  ROUND(
    COUNTIF(
      COALESCE(pe.encounter_count, 0) >= 6
    ) * 100.0 / COUNT(*),
    2
  ) AS high_utilization_rate,

  ROUND(
    AVG(COALESCE(pe.encounter_count, 0)),
    2
  ) AS avg_encounters_per_patient,

  ROUND(
    AVG(COALESCE(pe.emergency_encounters, 0)),
    2
  ) AS avg_emergency_encounters,

  ROUND(
    AVG(COALESCE(pe.inpatient_encounters, 0)),
    2
  ) AS avg_inpatient_encounters,

  ROUND(
    SUM(COALESCE(pe.worsened_encounters, 0)) * 100.0
    / NULLIF(SUM(COALESCE(pe.total_outcomes, 0)), 0),
    2
  ) AS worsening_rate

FROM `healthcare-data-analytic.healthcare_data_analysis.patients` p

LEFT JOIN patient_encounters pe
  ON p.Patient_ID = pe.Patient_ID

GROUP BY
  p.Risk_Category,
  p.Primary_Condition

ORDER BY
  CASE p.Risk_Category
    WHEN 'High' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'Low' THEN 3
  END,
  high_utilization_rate DESC;












