# Econometric Analysis of SPY Returns Using Lagged Market Indicators

## Overview

This project examines whether historical market information can help explain or predict daily returns of the SPDR S&P 500 ETF (SPY). Using daily financial data from 2015 through 2025, the analysis applies econometric regression techniques in R to investigate the relationship between previous-day market conditions and subsequent SPY returns.

The project focuses on three explanatory variables: lagged daily returns, lagged trading volume changes, and the CBOE Volatility Index (VIX).

## Research Question

Can yesterday's market information predict today's SPY return?

Specifically, the analysis investigates whether previous-day returns, trading volume changes, and market volatility contain information about subsequent daily SPY returns.

## Data and Variables

Daily historical data is obtained from Yahoo Finance using the `quantmod` package.

**Dependent Variable**
- Daily SPY return: Percentage change in SPY's closing price.

**Independent Variables**
- Lagged SPY return: Previous trading day's percentage return.
- Lagged volume change: Previous trading day's percentage change in trading volume.
- Lagged VIX: Previous trading day's VIX closing value.
- Down-day indicator: Binary variable equal to 1 when the previous day's SPY return was negative and 0 otherwise.

**Sample Period:** January 2015 – December 2025.

## Methodology

The analysis follows several stages:

1. Data Collection: Download daily SPY prices, trading volume, and VIX values.
2. Data Preparation: Align observations by trading date, calculate daily returns and volume changes, and construct lagged explanatory variables.
3. Descriptive Statistics: Calculate sample size, mean, standard deviation, minimum, and maximum for the model variables.
4. Visualization: Examine return distributions, lagged return relationships, and changes in market volatility over time.
5. Econometric Modeling: Estimate three Ordinary Least Squares (OLS) regression models.

### Regression Specifications

**Model 1: Simple Regression**

Daily SPY returns are regressed against the previous trading day's return.

**Model 2: Multiple Regression**

Lagged returns, lagged volume changes, and lagged VIX values are included as explanatory variables.

**Model 3: Extended Multiple Regression**

A binary indicator identifying whether the previous trading day was negative is added to the multiple regression model.

Model coefficients, standard errors, p-values, and R-squared values are examined to evaluate the relationships between the explanatory variables and subsequent returns.

## Visualizations

The project generates four visualizations:

- Distribution of daily SPY returns.
- Relationship between today's return and yesterday's return.
- Relationship between today's return and yesterday's VIX.
- VIX movements over the sample period.

## Technologies and Libraries

- R
- quantmod
- dplyr
- ggplot2
- Ordinary Least Squares (OLS)
- Time-series data manipulation
- Statistical inference and regression analysis

## Project Objectives

This project demonstrates the application of econometric techniques to financial market data, with an emphasis on time-series preparation, regression modeling, statistical inference, and financial data visualization.

It also provides an opportunity to examine the limitations of predicting daily equity returns, where market movements are often noisy and difficult to forecast.

## Limitations and Future Improvements

Potential extensions include:

- Evaluating predictive performance using out-of-sample testing.
- Comparing alternative regression specifications.
- Examining autocorrelation and heteroskedasticity in regression residuals.
- Applying heteroskedasticity-robust standard errors.
- Investigating whether model predictions can support a systematic trading strategy.

## Disclaimer

This project is for educational and research purposes only. It does not constitute investment advice or a recommendation to trade SPY.
