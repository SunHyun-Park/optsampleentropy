# Stroke Prediction Data Preprocessing

This repository provides the data preprocessing pipeline for the **Healthcare Stroke Prediction Dataset** used in the real-data application of our research on risk prediction under measurement constraints.

The purpose of this repository is to provide a clean and reproducible version of the stroke dataset that can be readily used for statistical modeling and risk prediction analyses.

## Dataset

The original dataset is the **Healthcare Stroke Prediction Dataset**, publicly available on Kaggle.

- Number of observations: 5,110
- Number of attributes: 12
- Response variable: `stroke`
- `stroke = 1`: patient experienced a stroke
- `stroke = 0`: patient did not experience a stroke

The dataset contains demographic, clinical, and lifestyle information related to stroke risk.

Dataset source:

https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset

## Data Preprocessing

The preprocessing procedure follows the real-data application described in:

> Park, S. and Lee, S.-H.  
> *Surrogate-assisted optimal sampling for risk prediction under measurement constraints.*

The following preprocessing steps are applied:

1. Remove observations with missing values in `bmi`.
2. Remove the observation with `gender = "Other"`.
3. Remove observations with `smoking_status = "Unknown"`, since this category represents unavailable smoking information.
4. Retain complete observations for subsequent statistical analysis.

After preprocessing, **3,425 observations** remain in the final dataset.

No outcome-based filtering or sampling procedure is applied during the preprocessing stage.

## Repository Structure

```text
data-preprocessing-repository/
├── README.md
├── data/
│   └── processed_data.csv
├── code/
│   └── data_preprocessing.R
└── data_dictionary.md
