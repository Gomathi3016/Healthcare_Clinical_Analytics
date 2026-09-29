# Healthcare & Clinical Analytics

Healthcare and clinical analytics project focused on patient demographics, healthcare utilization, clinical outcomes, laboratory data, diagnoses, medication patterns, and high-utilization patient segments.

This project uses synthetic healthcare data and demonstrates an end-to-end data analytics workflow using BigQuery, Python, and Power BI.

## Project Overview

The objective is to analyze healthcare utilization and clinical patterns across a synthetic patient population.

The analysis focuses on:

- Patient demographics and clinical risk
- Primary condition distribution
- Healthcare encounter utilization
- Encounter outcomes
- Emergency and inpatient utilization
- Laboratory result distributions
- Diagnosis prevalence and diagnosis burden
- Medication utilization
- High-utilization patients
- Regional healthcare patterns
- Data quality

## Business Questions

The project answers questions such as:

- What does the patient population look like?
- Which primary conditions are most common?
- Which encounter types account for the most healthcare activity?
- What are the most common encounter outcomes?
- Does risk category relate to healthcare utilization?
- Which patient groups have higher utilization?
- How do laboratory results vary across risk groups?
- Which diagnoses and medications are most frequently recorded?
- Where are high-utilization patients concentrated?
- Are there important data-quality issues?

## Datasets

| Dataset | Records | Description |

| patients.csv | 12,000 | Patient demographics, risk, condition, and region |
| encounters.csv | 30,000 | Healthcare encounter records |
| labs.csv | 90,000 | Laboratory test results |
| diagnoses.csv | 45,000 | Recorded diagnosis information |
| medications.csv | 36,000 | Medication utilization and status |
| data_dictionary.csv | 29 | Column definitions |

## Technology Stack

- BigQuery
- SQL
- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Power BI
- GitHub

## Project Workflow

Dataset
→ BigQuery
→ Data validation
→ SQL analysis
→ Python EDA
→ Power BI dashboard
→ Business insights
→ GitHub documentation

## Data Model

The patient table acts as the central entity.

patients
├── encounters
├── labs
├── diagnoses
└── medications

The primary relationship key is:

**Patient_ID**

All four clinical datasets were validated against the patient table and produced zero orphan Patient_ID records.

## Data Validation

The main tables were validated for row counts and referential integrity.

Validation results:

- Patients: 12,000
- Encounters: 30,000
- Labs: 90,000
- Diagnoses: 45,000
- Medications: 36,000
- All Patient_ID relationship checks: 0 orphan records

Data-quality issues were also identified:

- 60 Unknown gender values
- 90 Unknown encounter outcomes
- 120 missing laboratory results
- 75 invalid diagnosis codes marked as UNK

## Key Performance Metrics

- Total patients: 12,000
- Average age: 51.9 years
- Total encounters: 30,000
- Average encounters per patient: approximately 2.72
- Emergency encounter rate: 16.66%
- Inpatient encounter rate: 11.97%
- Improvement rate: approximately 42%
- Worsening rate: approximately 8%
- High-utilization patients: 479
- High-utilization threshold: 6 or more encounters
- Missing laboratory results: 120

## Key Analytical Findings

### Patient Population

Medium-risk patients form the largest risk group with 5,448 patients, followed by Low risk with 4,183 and High risk with 2,369.

Among primary conditions, Diabetes and Hypertension are the two largest specific chronic-condition groups.

### Healthcare Utilization

Outpatient encounters represent 49.74% of all encounters, followed by:

- Follow-up: 21.62%
- Emergency: 16.66%
- Inpatient: 11.97%

Inpatient encounters have the longest average length of stay at approximately 5.91 days.

### Encounter Outcomes

Improved and Stable are the two dominant encounter outcomes.

Across the full dataset:

- Improved: approximately 41.8%
- Stable: approximately 37.8%
- Referred: approximately 12.1%
- Worsened: approximately 8.0%

Outcome distributions remain relatively similar across encounter types, risk categories, and regions.

### Risk and Utilization

High-risk patients have a high-utilization rate of 4.39%, compared with 3.95% for Medium risk and 3.83% for Low risk.

The differences are relatively modest, indicating that risk category alone does not strongly explain healthcare utilization.

### High-Utilization Patients

Patients with 6 or more encounters were classified as high-utilization patients.

There are 479 high-utilization patients, representing approximately 3.99% of the total patient population.

Within this segment:

- Average encounters per patient: 6.47
- 351 patients had at least one emergency encounter
- 241 patients had at least one inpatient encounter

The highest high-utilization rate in the integrated analysis occurs among High-risk patients with Diabetes at approximately 6.08%.

### Laboratory Analysis

Six laboratory tests were analyzed:

- HbA1c
- Glucose
- Creatinine
- Hemoglobin
- LDL Cholesterol
- Systolic Blood Pressure

Missing laboratory results account for only 120 records, or approximately 0.13% of all laboratory records.

The average laboratory values across Low, Medium, and High risk groups are relatively similar, while within-group variability is much larger.

Statistical outlier analysis was performed using the IQR method.

### Diagnosis Analysis

The six tracked diagnosis categories have broadly similar record volumes.

Type 2 Diabetes has the highest number of recorded diagnosis records at 7,586.

Among patients with at least one valid diagnosis, most patients have between 2 and 4 distinct recorded diagnoses.

### Medication Analysis

Medication utilization is relatively balanced across the six medications:

- Amlodipine
- Salbutamol
- Aspirin
- Lisinopril
- Atorvastatin
- Metformin

Amlodipine has the highest recorded medication volume, while Metformin has the lowest.

## Power BI Dashboard

The Power BI dashboard provides an interactive view of:

- Patient risk distribution
- Healthcare encounters by type
- Encounter outcomes
- High-utilization rate by risk and condition
- Monthly encounter trends
- Diagnosis utilization
- Medication utilization

Dashboard filters include:

- Year
- Region
- Risk Category
- Primary Condition
- Age Group
- Encounter Type
- Outcome


## Skills Demonstrated

- SQL data analysis
- BigQuery
- Data validation
- Relational data modeling
- Data cleaning
- Exploratory data analysis
- Pandas
- NumPy
- Statistical analysis
- Data visualization
- Power BI
- DAX
- KPI development
- Interactive dashboard design
- Business insight generation
- Data-quality analysis
- GitHub documentation

## Business Value

The project demonstrates how healthcare datasets can be transformed into structured analytical insights covering patient populations, utilization, outcomes, clinical measurements, diagnoses, medications, and high-utilization segments.

The analysis can support further investigation into healthcare utilization patterns, operational planning, clinical research questions, and data-quality improvement.

## Conclusion

The analysis shows that healthcare utilization and encounter outcomes are relatively stable across many broad population groups, while specific combinations of risk and primary condition provide more useful segmentation.

High-utilization analysis highlights smaller patient segments that may warrant additional operational investigation, while laboratory, diagnosis, medication, and data-quality analysis provide supporting clinical context.

Because the dataset is synthetic, the findings are intended for analytics portfolio demonstration rather than clinical decision-making.

## Author

Gomathi

Data Analyst | SQL | Python | Power BI | BigQuery
