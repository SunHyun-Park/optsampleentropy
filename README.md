# Optimal Sampling for Healthcare Stroke Data

This repository provides the data preprocessing pipeline for the **Healthcare Stroke Prediction Dataset** used in the real-data application of *Surrogate-assisted optimal sampling for risk prediction under measurement constraints*.

The study considers **optimal sampling for risk prediction under measurement constraints**, where only a limited number of response measurements can be obtained. This repository provides the processed healthcare stroke data used to evaluate the optimal sampling procedure in a rare-outcome prediction setting.

## Overview

The objective of the stroke data analysis is to predict the risk of stroke based on patients' demographic, clinical, and lifestyle information.

In this application, the binary response is defined as:

- `stroke = 1`: patient experienced a stroke
- `stroke = 0`: patient did not experience a stroke

The prevalence of stroke is approximately 5%, representing a rare-outcome prediction setting.

Since no surrogate information is available in this application, all observations are treated as surrogate-negative. Therefore, the proposed surrogate-assisted optimal sampling procedure reduces to a **covariate-assisted optimal sampling design**.

## Dataset

The original dataset is the **Healthcare Stroke Prediction Dataset**, publicly available on Kaggle.

- Number of observations: `5,110`
- Number of attributes: `12`
- Response variable: `stroke`

The dataset contains demographic, clinical, and lifestyle factors related to stroke risk.

### Data Source

https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset

## Data Preprocessing

The original dataset contains unavailable or irrelevant information. To construct the dataset used for the optimal sampling analysis, the following preprocessing steps are applied:

1. Remove observations with missing values in `bmi`.
2. Remove the observation with `gender = "Other"`.
3. Remove observations with `smoking_status = "Unknown"`, since this category represents unavailable smoking information.
4. Retain complete observations for subsequent analysis.

After preprocessing, **3,425 observations** remain in the final dataset.

## Reproducibility

Download the original **Healthcare Stroke Prediction Dataset** from Kaggle and use the preprocessing script provided in this repository.

Run the following command in R:

```r
source("code/data_preprocessing.R")
```

The preprocessing script generates:

```text
data/processed_data.csv
```

The resulting dataset is the analysis-ready dataset used for the healthcare stroke application and can be used for statistical modeling, risk prediction, and optimal sampling analyses.

## Directory and Codes

```text
.
├── README.md
├── data
│   └── processed_data.csv
├── code
│   └── data_preprocessing.R
└── data_dictionary.md
```

- `data/processed_data.csv`: processed Healthcare Stroke Prediction Dataset
- `code/data_preprocessing.R`: R code used to preprocess the original dataset
- `data_dictionary.md`: descriptions of variables included in the processed dataset

## Optimal Sampling Application

The processed dataset was used in the stroke prediction application of:

**Park, S. and Lee, S.-H.**  
*Surrogate-assisted optimal sampling for risk prediction under measurement constraints.*

The study proposes an **optimal sampling framework for risk prediction under measurement constraints**, with sampling probabilities designed to improve out-of-sample prediction performance.

For the healthcare stroke data, no surrogate information is available. Consequently, the proposed method operates as a **covariate-assisted optimal sampling design**, where sampling is guided by patient covariates under a limited response measurement budget.

This repository provides the data preprocessing component for the healthcare stroke application. The implementation of the proposed optimal sampling methodology is not included in this repository.

## Citation

If you use this preprocessing pipeline or dataset preparation procedure in academic work, please cite:

```bibtex
@misc{park2026surrogate,
  title={Surrogate-assisted optimal sampling for risk prediction under measurement constraints},
  author={Park, Sunhyun and Lee, Seong-ho},
  year={2026},
  eprint={2606.03477},
  archivePrefix={arXiv},
  primaryClass={stat.ME}
}
```

## Acknowledgement

This repository was developed with support from the **서울시립대학교 데이터 사이언스 플러스 차세대 융합인재 양성사업단** - http://dsplus.uos.ac.kr/
