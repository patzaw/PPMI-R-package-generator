<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Disclaimer

This package is in no way officially related to or endorsed by the PPMI.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Background

In the field of Parkinson’s disease (PD) therapeutics, the ultimate goal is to
develop disease-modifying treatments that slow, prevent or reverse the
underlying disease process. Validated biomarkers of disease progression would
dramatically accelerate PD therapeutics research.
Current progression biomarkers, however, are not optimal and are not
fully validated.
(source: [PPMI website](http://www.ppmi-info.org/about-ppmi/))

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Rationale for PPMI

PPMI (Parkinson's Progression Markers Initiative)
is an observational clinical study to verify progression markers in
Parkinson’s disease. PPMI has emerged as a model for following multiple
cohorts of significant interest and is being conducted at a network of
clinical sites around the world. The study is designed to establish a
comprehensive set of clinical, imaging and biosample data that will be used
to define biomarkers of PD progression.
Once these biomarkers are defined, they can be used in therapeutic studies,
which is the ultimate goal.
(source: [PPMI website](http://www.ppmi-info.org/about-ppmi/))

PPMI will follow standardized data acquisition protocols to ensure that
tests and assessments conducted at multiple sites and across multiple cohorts
can be pooled in centralized databases and repositories.
The clinical, imaging and biologic data will be easily accessible
to researchers in real time through
the [PPMI website](http://www.ppmi-info.org/about-ppmi/).
The biological samples collected throughout the course of PPMI will
be stored in a central repository that will be accessible to any scientist
with promising biomarker leads for the purposes of verifying initial
results and assessing correlations to clinical outcomes and other biomarkers.
(source: [PPMI website](http://www.ppmi-info.org/about-ppmi/))

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Data source

Data are dumped from the
[PPMI repository](https://www.ppmi-info.org/access-data-specimens/download-data/). They
are then preprocessed, and derived variables are computed as
recommended by the PPMI.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Data preprocessing

The following files are parsed using the **D01-PPMI-Parsing.Rmd** script.

    - Benton_Judgment_of_Line_Orientation.csv
    - Blood_Chemistry___Hematology.csv
    - Center-Subject_List.csv
    - Clinical_Diagnosis_and_Management.csv
    - Code_List.csv
    - Cognitive_Categorization.csv
    - Concomitant_Medications.csv
    - Current_Biospecimen_Analysis_Results.csv
    - Data_Dictionary.csv
    - DATScan_Analysis.csv
    - DaTscan_Imaging.csv
    - Diagnostic_Features.csv
    - Epworth_Sleepiness_Scale.csv
    - Family_History__PD_.csv
    - General_Neurological_Exam.csv
    - General_Physical_Exam.csv
    - Genetic_Testing_Results.csv
    - Geriatric_Depression_Scale__Short_.csv
    - Hopkins_Verbal_Learning_Test.csv
    - Letter_-_Number_Sequencing__PD_.csv
    - Magnetic_Resonance_Imaging.csv
    - MDS_UPDRS_Part_I__Patient_Questionnaire.csv
    - MDS_UPDRS_Part_I.csv
    - MDS_UPDRS_Part_II__Patient_Questionnaire.csv
    - MDS_UPDRS_Part_III.csv
    - MDS_UPDRS_Part_IV.csv
    - Modified_Schwab_+_England_ADL.csv
    - Montreal_Cognitive_Assessment__MoCA_.csv
    - Neurological_Exam_-_Cranial_Nerves.csv
    - Patient_Status.csv
    - PD_Features.csv
    - PPMI_PD_Variants_Genetic_Status_WGS_20180921.csv
    - Primary_Diagnosis.csv
    - QUIP_Current_Short.csv
    - REM_Sleep_Disorder_Questionnaire.csv
    - SCOPA-AUT.csv
    - Screening___Demographics.csv
    - Semantic_Fluency.csv
    - Socio-Economics.csv
    - State-Trait_Anxiety_Inventory.csv
    - Symbol_Digit_Modalities.csv
    - TAP-PD_Kinetics_Device_Testing.csv
    - University_of_Pennsylvania_Smell_ID_Test.csv
    - Use_of_PD_Medication.csv
    - Vital_Signs.csv

The following objects are created and saved in the **PPMI-Parsed.rda** file.

    - `dumpDate`
    - `visitDoc`
    - `visitInfo`
    - `scheduledVisits`
    - `varDoc`
    - `patientData`
    - `visitData`

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Derived variables

This document describes how PPMI variables were derived from the
original parsed data.

Derived variables are computed using the **D02-PPMI-Variables.Rmd** script
as described in the *Derived_Variable_Definitions_and_Score_Calculations.csv*
<!-- *PPMI\_Derived\_Variable\_Definitions\_and\_Score\_Calculations20151201.pdf* --> <!-- For 2016-01-11 and before -->
file.

The former objects are updated and saved in the **PPMI-Derived.rda** file.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Genotyping data

Genotyping data were downloaded and the **IMMUNO** SNP coordinates were
converted into GRCh37 before merging with the **NEUROX** SNPs using
the [plink](http://zzz.bwh.harvard.edu/plink/) software:

```
plink --bfile IMMUNO-GRCh37 --bmerge NEUROX.bed NEUROX.bim NEUROX.fam --make-bed --out ImmunoNeurox-GRCh37

## - mind:0.6 because the 2 arrays were performed on different individuals:
## 0.6 corresponds approximatevely to the proportion of SNPs on one array
## compared to the sum of the 2 arrays

## geno:0.2 because the 2 arrays were performed on different individuals:
## 0.2 corresponds approximatevely to the proportion of individuals
## on one array compared to the sum of the 2 arrays

plink --bfile ImmunoNeurox-GRCh37 --mind 0.6 --maf 0.05 --geno 0.2 --hwe 0.001 --make-bed --out ImmunoNeurox-GRCh37-Filtered
```

The GRCh37 coordinates for the **IMMUNO** SNPs are available in the
**Genotyping/IMMUNO-GRCh37.bim** file. After download, the files
**IMMUNO.bed** and **IMMUNO.fam** need to be renamed
**IMMUNO-GRCh37.bed** and **IMMUNO-GRCh37.fam** respectively before merging.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## R package generation

The PPMI R package is generated using the **S01-PackageGenerator.R** script.
This script also builds the "PPMI-Data-Usage" vignette using updated data.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Data export in Excel file

After building and installing the PPMI R package, data can be exported in
an Excel file using the **Data-Summary-Export.Rmd** script.

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
## Data export in SAS

After building and installing the PPMI R package, data can be exported in
an SAS XPORT file using the **Export-SAS.R** script. However the function
from the **SASxport** package (`write.xport()`) used to build this file raises
several messages about truncated long names. Also in the PPMI R package,
row names are used to make cross-references between data frames. I don't
know has row names are exported by **SASxport** and how they are handled by
SAS itself. CSV files are also produced by this script.
