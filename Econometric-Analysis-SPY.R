# ============================================================
# Can yesterday's information predict today's SPY return?
# Question: Do lagged return, lagged volume change, and the VIX
#           predict the next day's S&P 500 ETF (SPY) return?
# Tools: dplyr, ggplot2, lm  (all covered in the course)
# ============================================================

# ---- 0. SETUP ----------------------------------------------
# install.packages(c("quantmod", "dplyr", "ggplot2"))  # run once
library(quantmod)   # downloads free price data from Yahoo Finance
library(dplyr)      # data manipulation
library(ggplot2)    # plots

# ---- 1. GET THE DATA ---------------------------------------
# getSymbols downloads daily data. auto.assign = FALSE returns the
# data instead of creating a hidden variable in your environment.
spy <- getSymbols("SPY",  src = "yahoo", from = "2015-01-01",
                  to = "2025-12-31", auto.assign = FALSE)
vix <- getSymbols("^VIX", src = "yahoo", from = "2015-01-01",
                  to = "2025-12-31", auto.assign = FALSE)

# The data comes as an "xts" time series. Convert to ordinary data frames.
# Cl() = closing price, Vo() = volume (quantmod helper functions).
spy_df <- data.frame(date   = index(spy),
                     price  = as.numeric(Cl(spy)),
                     volume = as.numeric(Vo(spy)))
vix_df <- data.frame(date = index(vix),
                     vix  = as.numeric(Cl(vix)))

# ---- 2. CLEAN AND BUILD VARIABLES --------------------------
dat <- spy_df %>%
  inner_join(vix_df, by = "date") %>%          # keep days present in both
  arrange(date) %>%                            # lag() needs correct ordering
  mutate(
    # daily return in percent: (today - yesterday) / yesterday * 100
    ret        = (price / lag(price) - 1) * 100,
    # daily % change in volume
    vol_change = (volume / lag(volume) - 1) * 100,
    # lag() shifts a column down one row, so each row sees YESTERDAY's value
    ret_lag      = lag(ret),
    volchg_lag   = lag(vol_change),
    vix_lag      = lag(vix)
  ) %>%
  filter(!is.na(ret_lag), !is.na(volchg_lag))  # drop first rows with no lag

# Dummy variable: was yesterday a down day? (1 = yes, 0 = no)
dat <- dat %>% mutate(down_lag = as.numeric(ret_lag < 0))

# ---- 3. SUMMARY STATISTICS (all variables used in models) --
vars <- dat %>% select(ret, ret_lag, volchg_lag, vix_lag, down_lag)

summary_table <- data.frame(
  variable = names(vars),
  n    = sapply(vars, function(x) sum(!is.na(x))),
  mean = sapply(vars, mean),
  sd   = sapply(vars, sd),
  min  = sapply(vars, min),
  max  = sapply(vars, max),
  row.names = NULL
)
print(summary_table, digits = 3)

# ---- 4. VISUALIZATIONS (need at least three) ---------------
# Plot 1: histogram of daily returns (shows fat tails)
p1 <- ggplot(dat, aes(x = ret)) +
  geom_histogram(bins = 80, fill = "steelblue") +
  labs(title = "Distribution of Daily SPY Returns",
       x = "Daily return (%)", y = "Number of days")

# Plot 2: today's return vs. yesterday's return
p2 <- ggplot(dat, aes(x = ret_lag, y = ret)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", color = "red") +   # fitted regression line
  labs(title = "Today's Return vs. Yesterday's Return",
       x = "Yesterday's return (%)", y = "Today's return (%)")

# Plot 3: today's return vs. yesterday's VIX
p3 <- ggplot(dat, aes(x = vix_lag, y = ret)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Today's Return vs. Yesterday's VIX",
       x = "VIX (previous day close)", y = "Today's return (%)")

# Plot 4: VIX over time (volatility clusters, e.g. 2020 COVID spike)
p4 <- ggplot(dat, aes(x = date, y = vix)) +
  geom_line(color = "darkgreen") +
  labs(title = "VIX Over Time", x = "Date", y = "VIX")

# Show plots, and save them for the paper/poster
print(p1); print(p2); print(p3); print(p4)
ggsave("fig1_hist.png", p1, width = 6, height = 4)
ggsave("fig2_ret_lag.png", p2, width = 6, height = 4)
ggsave("fig3_vix.png", p3, width = 6, height = 4)
ggsave("fig4_vix_time.png", p4, width = 6, height = 4)

# ---- 5. REGRESSIONS ----------------------------------------
# Model 1 (simple): ret = b0 + b1*ret_lag + e
m1 <- lm(ret ~ ret_lag, data = dat)

# Model 2 (multiple): add lagged volume change and lagged VIX
m2 <- lm(ret ~ ret_lag + volchg_lag + vix_lag, data = dat)

# Model 3 (multiple): add the "yesterday was a down day" dummy
m3 <- lm(ret ~ ret_lag + volchg_lag + vix_lag + down_lag, data = dat)

summary(m1)
summary(m2)
summary(m3)

# How to read each summary() output:
#  Estimate   = predicted change in today's return (in percentage points)
#               for a 1-unit increase in that variable, others held fixed
#  Std. Error = uncertainty in that estimate
#  Pr(>|t|)   = p-value; below 0.05 is the usual "statistically significant"
#  R-squared  = share of the variation in daily returns the model explains
#               (expect it to be tiny: daily returns are mostly noise)

# Side-by-side coefficient comparison
comparison <- data.frame(
  term = names(coef(m3)),
  model3_estimate = coef(m3),
  model3_pvalue = summary(m3)$coefficients[, 4],
  row.names = NULL
)
print(comparison, digits = 3)

