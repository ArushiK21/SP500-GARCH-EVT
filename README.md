# **S&P 500 Risk Modeling using GARCH, EVT and VaR Backtesting**

This project applies a two-step **GARCH-EVT framework** to model volatility persistence, heavy tails, and extreme downside risk in the S&P 500.

The analysis combines:

* **Log return analysis**
* **Exploratory data analysis**
* **GARCH(1,1) volatility modeling**
* **Student-t innovations**
* **Extreme Value Theory**
* **Peaks-Over-Threshold method**
* **Value at Risk backtesting**
* **Kupiec Proportion of Failures test**

The goal is to evaluate whether combining dynamic volatility modeling with tail-risk analysis improves Value at Risk forecasts compared with simpler benchmark approaches.

---

## **1. Project Overview**

Financial returns often violate the assumptions of standard risk models. In practice, market returns show volatility clustering, negative skewness, fat tails, and extreme crash behavior. These features make standard normal-distribution-based Value at Risk models unreliable during market stress.

This project studies the S&P 500 as a major U.S. equity market benchmark and applies a two-step methodology:

1. **GARCH(1,1)** is used to model time-varying volatility and volatility persistence.
2. **Extreme Value Theory (EVT)** is applied to the standardized residuals to model the extreme tail of the return distribution.

The final model is evaluated using a 99% Value at Risk backtesting framework and compared against historical VaR, normal VaR, and GARCH-t VaR.

---

## **2. Repository Contents**

This repository contains the complete project workflow, including:

* Raw S&P 500 price data
* Processed log return data
* Full R code for data retrieval, preprocessing, GARCH modeling, EVT estimation, and VaR backtesting
* Generated plots and result tables
* Final academic paper explaining the methodology and findings

The repository is designed to make the project reproducible from raw data preparation to final risk model evaluation.

---

## **3. Research Motivation**

Traditional risk models often assume that returns are normally distributed and that volatility is constant over time. These assumptions are weak for equity markets, especially during crises.

The S&P 500 shows several stylized facts:

* Volatility clustering
* Heavy-tailed return distribution
* Negative skewness
* Extreme losses during market stress
* Non-normal behavior during crash periods

The COVID-19 crash in early 2020 provides a clear example of why models must account for both changing volatility and extreme downside events.

This project asks:

**Can a GARCH-EVT framework produce better 99% VaR forecasts than standard VaR models during periods of market stress?**

---

## **4. Data Description**

### **4.1 Asset**

The project analyzes the:

**S&P 500 Index**

The S&P 500 is used because it is one of the most widely followed benchmarks for U.S. equity market performance.

### **4.2 Data Source**

The data was retrieved using the `quantmod` package in R.

The analysis uses:

* Daily adjusted closing prices
* S&P 500 ticker: `^GSPC`

### **4.3 Sample Period**

The dataset covers:

**January 2014 to January 2026**

### **4.4 Frequency**

The analysis uses:

**Daily trading data**

### **4.5 Return Calculation**

Daily logarithmic returns are calculated as:

```text
r_t = ln(P_t) - ln(P_{t-1})
```

where:

* `P_t` is the adjusted closing price at time `t`
* `P_{t-1}` is the adjusted closing price from the previous trading day
* `r_t` is the daily log return

Log returns are used because they are standard in financial time-series analysis and are suitable for volatility and risk modeling.

---

## **5. Exploratory Data Analysis**

The exploratory analysis shows that the S&P 500 price series has a long-term upward trend, but also contains sharp drawdowns during periods of market stress.

The log return series reveals important financial stylized facts:

* Calm periods are followed by more calm periods
* Volatile periods are followed by more volatile periods
* Extreme losses occur more often than a normal distribution would suggest
* The 2020 COVID-19 crash appears as a major volatility shock

The dataset contains **3,037 trading days**.

Key descriptive statistics from the analysis include:

| Statistic            |   Value |
| -------------------- | ------: |
| Mean daily return    | 0.0439% |
| Standard deviation   | 1.0999% |
| Maximum daily return |   9.09% |
| Minimum daily return | -12.76% |
| Skewness             | -0.6611 |
| Kurtosis             | 16.3103 |

The negative skewness indicates that downside movements are more severe than upside movements. The high kurtosis confirms that the return distribution has fat tails.

These findings motivate the use of GARCH for volatility clustering and EVT for extreme tail modeling.

---

## **6. Methodology**

The project follows a two-step risk modeling framework.

---

### **6.1 Value at Risk**

Value at Risk estimates the maximum expected loss over a given horizon at a selected confidence level.

For a 99% one-day VaR model, losses should exceed the VaR threshold on approximately 1% of trading days.

---

### **6.2 Expected Shortfall**

Expected Shortfall measures the average loss when the VaR threshold is breached.

While VaR identifies the loss cutoff, Expected Shortfall provides information about the severity of losses beyond that cutoff.

---

### **6.3 GARCH(1,1) Volatility Modeling**

The first stage applies a **GARCH(1,1)** model with Student-t errors to capture time-varying volatility.

The GARCH model is specified as:

```text
σ_t² = ω + αε_{t-1}² + βσ_{t-1}²
```

where:

* `ω` is the baseline variance
* `α` captures the impact of recent shocks
* `β` captures volatility persistence
* `σ_t²` is the conditional variance

Student-t errors are used because financial returns have fatter tails than a normal distribution.

### **GARCH(1,1)-t Model Estimates**

| Parameter         | Estimate |
| ----------------- | -------: |
| Mean              | 0.093881 |
| Baseline variance | 0.023944 |
| ARCH term         | 0.178282 |
| GARCH term        | 0.815401 |
| Student-t shape   | 5.291381 |

The persistence value is:

```text
α + β = 0.993683
```

This shows that volatility shocks are highly persistent and fade slowly over time.

---

### **6.4 Extreme Value Theory**

After fitting the GARCH model, standardized residuals are extracted. EVT is then applied to model the most extreme losses.

The project uses the **Peaks-Over-Threshold (POT)** method.

The POT method focuses only on observations that exceed a high threshold. These exceedances are modeled using the **Generalized Pareto Distribution (GPD)**.

### **GPD Tail Parameters**

| Parameter   | Estimate |
| ----------- | -------: |
| Threshold   |   1.7843 |
| Exceedances |      152 |
| Shape       | 0.162963 |
| Scale       | 0.665901 |

The positive shape parameter indicates heavy-tailed behavior. This means that extreme losses occur more often than normal-distribution-based models would predict.

---

### **6.5 VaR Backtesting**

The models are evaluated using the **Kupiec Proportion of Failures (POF) test**.

The Kupiec test checks whether the observed number of VaR violations matches the expected number of violations.

For a 99% VaR model, the expected breach rate is approximately 1%.

A model performs well if:

* The actual breach rate is close to 1%
* The Kupiec p-value does not reject the model

---

## **7. Models Compared**

The project compares four VaR models:

1. **Historical VaR**
2. **Normal VaR**
3. **GARCH-t VaR**
4. **GARCH-EVT VaR**

---

## **8. Key Results**

### **8.1 VaR Backtesting Performance**

| Model          | VaR Level | Violations | Actual Breach Rate | Kupiec p-value |
| -------------- | --------: | ---------: | -----------------: | -------------: |
| Historical VaR |       99% |         29 |             0.0142 |         0.0708 |
| Normal VaR     |       99% |         56 |             0.0275 |         0.0000 |
| GARCH-t VaR    |       99% |         38 |             0.0187 |         0.0005 |
| GARCH-EVT VaR  |       99% |         23 |             0.0113 |         0.5661 |

The GARCH-EVT model performed best among the tested approaches.

It recorded:

```text
23 violations across 2,037 trading days
```

This corresponds to:

```text
1.13% breach rate
```

The target breach rate for a 99% VaR model is 1%, so the GARCH-EVT result is closely aligned with the expected value.

The Kupiec p-value of **0.5661** indicates that the model is not rejected by the backtesting test.

---

## **9. Main Findings**

The project leads to several key findings:

1. S&P 500 returns are not normally distributed.
2. The return distribution is negatively skewed and highly leptokurtic.
3. Volatility clustering is clearly present in the data.
4. GARCH(1,1) captures volatility persistence effectively.
5. The persistence estimate is close to 1, showing that shocks fade slowly.
6. EVT confirms the presence of heavy tails in the standardized residuals.
7. Normal VaR strongly underestimates downside risk.
8. GARCH-t improves on normal VaR but still fails the Kupiec test.
9. GARCH-EVT provides the best VaR calibration.
10. Combining dynamic volatility modeling with tail-risk modeling improves risk forecasts.

---

## **10. Interpretation**

The results show that risk models should not rely only on normality assumptions. During market stress, extreme losses occur more frequently than standard models predict.

The GARCH-EVT framework performs better because it captures two important features at the same time:

* **GARCH** captures changing volatility over time.
* **EVT** captures rare and extreme tail losses.

This combination makes the model more reliable for estimating downside market risk.

---

## **11. Repository Structure**

```text
SP500-GARCH-EVT-Risk-Modeling/
│
├── README.md
│
├── data/
│   ├── raw/
│   │   └── prices_GSPC_2014_2026.csv
│   │
│   └── processed/
│       └── returns_GSPC_2014_2026.csv
│
├── code/
│   └── sp500_garch_evt_var_backtesting.R
│
├── results/
│   ├── descriptive_statistics.csv
│   ├── garch_model_results.csv
│   ├── gpd_tail_parameters.csv
│   ├── var_backtesting_results.csv
│   └── plots/
│       ├── sp500_prices.png
│       ├── sp500_log_returns.png
│       ├── return_distribution.png
│       ├── qq_plot.png
│       ├── acf_squared_returns.png
│       ├── conditional_volatility.png
│       ├── mean_excess_plot.png
│       └── var_overlay.png
│
└── paper/
    └── Arushi_Kulkarni_FinancialAnalytics.pdf
---

## **12. Tools and Libraries Used**

The project was implemented in **R**.

Main libraries used:

* `quantmod` for S&P 500 data retrieval
* `rugarch` for GARCH modeling
* `evir` for Extreme Value Theory and GPD fitting

Other tools:

* RStudio
* Excel or CSV files for storing raw and processed data
* GitHub for project documentation and version control

---

## **13. How to Run the Code**

### **Step 1: Install Required R Packages**

```r
install.packages("quantmod")
install.packages("rugarch")
install.packages("evir")
```

### **Step 2: Load the Libraries**

```r
library(quantmod)
library(rugarch)
library(evir)
```

### **Step 3: Run the Main R Script**

```r
source("code/sp500_garch_evt_var_backtesting.R")
```

The script performs:

* Data retrieval
* Log return calculation
* Exploratory analysis
* GARCH model fitting
* Standardized residual extraction
* EVT tail modeling
* VaR estimation
* Kupiec backtesting
* Result export

---

## **14. Limitations**

This project has several limitations:

* The analysis focuses only on the S&P 500.
* The EVT threshold and GPD parameters are estimated in-sample.
* EVT parameters remain static during the backtesting stage.
* The model uses daily data and does not capture intraday risk.
* Liquidity, macroeconomic variables, and cross-market contagion are not directly modeled.
* The framework evaluates VaR calibration but does not include a full Expected Shortfall backtest.

These limitations leave room for further improvement, especially in live risk management applications.

---

## **15. Future Work**

Future extensions could include:

* Rolling-window EVT parameter estimation
* Dynamic threshold selection
* Expected Shortfall backtesting
* Comparison with EGARCH or GJR-GARCH models
* Forecasting with asymmetric volatility models
* Multivariate risk modeling
* Portfolio-level VaR and ES estimation
* Stress testing using crisis-specific scenarios
* Comparing results with machine learning-based volatility models

---

## **16. Conclusion**

This project shows that standard VaR models can underestimate downside risk in the S&P 500, especially when returns show volatility clustering and fat tails.

The GARCH-EVT framework provides a stronger approach by combining dynamic volatility modeling with extreme tail estimation. In backtesting, the GARCH-EVT model achieved a breach rate of **1.13%**, close to the expected 1% level for a 99% VaR model.

Overall, the results suggest that advanced risk models are more suitable than simple Gaussian approaches when markets experience stress, volatility persistence, and extreme downside events.

---

## **17. Disclaimer**

This project is for academic and educational purposes only. It does not constitute financial advice, investment advice, or trading guidance. The results depend on the selected sample period, model assumptions, and implementation choices.
