# Optimal Sampling for Healthcare Stroke Data

This repository provides the R implementation of the healthcare stroke data application in:

**Park, S. and Lee, S.-H.**  
*Surrogate-assisted optimal sampling for risk prediction under measurement constraints.*

The study proposes an **optimal sampling framework for risk prediction under measurement constraints**, where response measurements are available only for a limited number of observations. The proposed sampling design directly targets out-of-sample prediction performance through the expected cross-entropy loss.

This repository demonstrates the application of the proposed framework to a rare-outcome stroke prediction problem using the **Healthcare Stroke Prediction Dataset**.

## Overview

<img width="1920" height="691" alt="framework" src="https://github.com/user-attachments/assets/0cb20fcb-6f82-4cee-941e-b7b0f3c476b7" />

The proposed framework considers a setting in which covariates \(X\) and a surrogate indicator \(S\) are available for all observations, while the true binary response \(Y\) is costly to obtain.

In the general surrogate-assisted setting:

- \(S=1\) identifies confirmed positive observations, so that \(Y=1\) is known.
- Observations with \(S=0\) form an unlabeled group whose true responses are not initially observed.
- Under a limited measurement budget \(C\), informative observations are selected from the \(S=0\) group.
- The selected observations are verified to obtain their true responses.
- A risk prediction model is then fitted using an inverse-probability-weighted cross-entropy estimator.

The proposed sampling probabilities are designed to minimize the leading contribution to the expected out-of-sample **cross-entropy loss**, thereby directly targeting binary risk prediction performance.

## Optimal Sampling without Surrogate Information

An important feature of the proposed framework is that it can also be applied when no surrogate information is available.

For the healthcare stroke application, we set

```text
S = 0 for all observations.
```

Therefore, every observation initially belongs to the unlabeled group, and there are no automatically identified surrogate-positive cases.

Under this setting, the surrogate-assisted framework reduces to a **covariate-assisted optimal sampling design**.

The sampling procedure uses patient covariates and a preliminary risk prediction model to identify informative observations under the measurement budget. Thus, the proposed method can still perform optimal sampling even when a positive-only surrogate is unavailable.

This application is particularly useful for evaluating the proposed method under a **rare-outcome setting**, since the prevalence of stroke in the dataset is approximately 5%.

## Proposed CE-based Optimal Sampling

Let \(p(x,\beta)\) denote the predicted probability of the binary response.

The proposed method selects sampling probabilities to improve the prediction performance of the estimated model under a fixed response measurement budget.

The procedure consists of the following steps:

1. Obtain a preliminary estimator from a pilot sample.
2. Compute the contribution of each observation to the leading cross-entropy prediction risk.
3. Determine optimal sampling probabilities under the measurement budget \(C\).
4. Sample observations according to the resulting probabilities.
5. Obtain the true responses for the selected observations.
6. Estimate the prediction model using an inverse-probability-weighted cross-entropy loss.

In contrast to sampling procedures based on parameter estimation error or prediction MSE, the proposed **CE method directly optimizes a criterion aligned with binary risk prediction**.

## Healthcare Stroke Dataset

The **Healthcare Stroke Prediction Dataset** contains demographic, clinical, and lifestyle information related to stroke risk.

The binary response is defined as:

- `stroke = 1`: patient experienced a stroke
- `stroke = 0`: patient did not experience a stroke

The original dataset contains:

- Number of observations: `5,110`
- Number of attributes: `12`
- Response variable: `stroke`

### Data Source

https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset

## Data Preprocessing

The same preprocessing procedure used in the real-data application of the paper is applied.

1. Remove observations with missing values in `bmi`.
2. Remove the observation with `gender = "Other"`.
3. Remove observations with `smoking_status = "Unknown"`.
4. Convert categorical variables into factors for subsequent analysis.

After preprocessing, **3,425 observations** remain.

The processed data are then converted into a design matrix for the prediction model.

## Experimental Setting

The healthcare stroke experiment evaluates the proposed CE-based optimal sampling method under limited response measurement budgets.

The experimental settings are:

- Pilot sample size: `m = 300`
- Measurement budgets: `C = 200, 300, 400`
- Number of repetitions: `1,000`
- Surrogate indicator: `S = 0` for all observations

The following methods are compared:

- **CE**: proposed cross-entropy-based optimal sampling
- **MSE**: MSE-based optimal sampling
- **OSCA**: surrogate-assisted sampling method
- **SRS**: simple random sampling
- **FULL**: estimator fitted using the full data as a benchmark

Since no surrogate information is available in the stroke application, OSCA reduces to simple random sampling.

Prediction performance is evaluated using:

- Cross-entropy loss (CE)
- Mean squared error (MSE)
- Specificity (TN)
- Sensitivity (TP)
- Area under the ROC curve (AUC)

## Reproducibility

Install the required R packages:

```r
install.packages(c(
  "data.table",
  "caret",
  "nloptr",
  "snowfall",
  "pROC",
  "ggplot2"
))
```

The main analysis uses the functions for the proposed CE-based optimal sampling method and the comparison methods.

For example, the analysis can be conducted under a pilot sample size of `m = 300` and measurement budget `C = 400`.

```r
m <- 300
C <- 400
```

The same procedure can be repeated for:

```text
C = 200
C = 300
C = 400
```

to reproduce the experimental settings considered in the paper.

## Directory and Codes

```text
.
├── README.md
├── data/
│   └── healthcare-dataset-stroke-data.csv
├── code/
│   ├── otherftn_ds.R
│   ├── stroke_ds.R
│   └── sum_ds.R
└── results/
```

### `code/otherftn_ds.R`

Contains the functions required for the analysis, including:

- CE-based optimal sampling
- MSE-based optimal sampling
- inverse-probability-weighted estimation
- maximum likelihood estimation
- OSCA
- prediction performance summaries

### `code/stroke_ds.R`

Runs the healthcare stroke data application, including:

- data preprocessing
- pilot sample construction
- optimal sampling probability calculation
- response sampling under measurement constraints
- model estimation
- repeated experiments

### `code/sum_ds.R`

Summarizes the simulation results and computes:

- CE
- MSE
- specificity
- sensitivity
- AUC

## Results

The healthcare stroke application demonstrates that the proposed **CE-based optimal sampling method remains effective even when no surrogate information is available**.

Under this setting, all observations belong to the initially unlabeled group and sampling is guided entirely by the available covariate information.

Across the considered measurement budgets, the proposed CE method achieves favorable prediction performance, particularly in terms of cross-entropy loss and AUC, compared with the competing subsampling approaches.

These results illustrate that the proposed framework is not restricted to settings with an available positive-only surrogate and can also be used as a **covariate-assisted optimal sampling procedure for rare-outcome prediction**.

## Citation

If you use this repository in academic work, please cite:

```bibtex
@article{park2026surrogate,
  title={Surrogate-assisted optimal sampling for risk prediction under measurement constraints},
  author={Park, Sunhyun and Lee, Seong-ho},
  journal={arXiv preprint arXiv:2606.03477},
  year={2026}
}
```

## Acknowledgement

This repository was developed with support from the 서울시립대학교 데이터 사이언스 플러스 차세대 융합인재 양성사업단 - http://dsplus.uos.ac.kr/
