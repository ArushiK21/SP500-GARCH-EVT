# ==========================================
# 02_eda.R - Exploratory Data Analysis & Stylized Facts
# ==========================================

# 1. Load setup and helpers
source("03_code/R/00_setup.R")

# 2. Load the processed data we just created
prices_df <- read.csv("02_data/raw/prices_GSPC_2014_2026.csv")
returns_df <- read.csv("02_data/processed/returns_GSPC_2014_2026.csv")

# Ensure Date columns are actually treated as dates by R
prices_df$Date <- as.Date(prices_df$Date)
returns_df$Date <- as.Date(returns_df$Date)

ret_vector <- returns_df$Log_Return_Pct

# ==========================================
# 3. Generate Summary Statistics Table
# ==========================================
summary_stats <- data.frame(
  Metric = c("Observations", "Mean (%)", "Min (%)", "Max (%)", 
             "Std. Dev. (%)", "Skewness", "Excess Kurtosis"),
  Value = c(
    length(ret_vector),
    round(mean(ret_vector), 4),
    round(min(ret_vector), 4),
    round(max(ret_vector), 4),
    round(sd(ret_vector), 4),
    round(skewness(ret_vector), 4),
    round(kurtosis(ret_vector) - 3, 4) # Excess kurtosis (subtract 3)
  )
)

save_table(summary_stats, "tab_01_summary_stats_GSPC.csv")

# ==========================================
# 4. Generate the 5 Stylized Fact Figures
# ==========================================

# Figure 1: Price Series
p1 <- ggplot(prices_df, aes(x = Date, y = Price)) +
  geom_line(color = "darkblue") +
  theme_minimal() +
  labs(title = "S&P 500 Daily Prices", x = "Date", y = "Price")
save_plot(p1, "fig_01_price_GSPC.png", width = 10, height = 5)

# Figure 2: Return Series (Shows volatility clustering)
p2 <- ggplot(returns_df, aes(x = Date, y = Log_Return_Pct)) +
  geom_line(color = "darkred", alpha = 0.8) +
  theme_minimal() +
  labs(title = "S&P 500 Daily Log Returns", x = "Date", y = "Log Returns (%)")
save_plot(p2, "fig_02_returns_GSPC.png", width = 10, height = 5)

# Figure 3: Histogram with Normal Curve Overlay (Shows heavy tails)
p3 <- ggplot(returns_df, aes(x = Log_Return_Pct)) +
  geom_histogram(aes(y = after_stat(density)), bins = 100, fill = "steelblue", color = "black", alpha = 0.7) +
  stat_function(fun = dnorm, args = list(mean = mean(ret_vector), sd = sd(ret_vector)), 
                color = "red", linewidth = 1) +
  theme_minimal() +
  labs(title = "Distribution of Daily Returns vs. Normal Distribution", x = "Log Return (%)", y = "Density")
save_plot(p3, "fig_03_hist_GSPC.png", width = 6, height = 6)

# Figure 4: QQ Plot (Another way to prove heavy tails for EVT justification)
p4 <- ggplot(returns_df, aes(sample = Log_Return_Pct)) +
  stat_qq(color = "darkblue", alpha = 0.5) +
  stat_qq_line(color = "red", linewidth = 1) +
  theme_minimal() +
  labs(title = "Normal Q-Q Plot of Daily Returns", x = "Theoretical Quantiles", y = "Sample Quantiles")
save_plot(p4, "fig_04_qq_GSPC.png", width = 6, height = 6)

# Figure 5: ACF of Squared Returns (Proves you NEED a GARCH model)
# We use base R's acf function, extract the data, and plot it cleanly in ggplot
acf_sq <- acf(ret_vector^2, lag.max = 40, plot = FALSE)
acf_df <- data.frame(Lag = acf_sq$lag[-1], ACF = acf_sq$acf[-1]) # drop lag 0

p5 <- ggplot(acf_df, aes(x = Lag, y = ACF)) +
  geom_segment(aes(xend = Lag, yend = 0), color = "darkred", linewidth = 1) +
  geom_hline(yintercept = 0, color = "black") +
  geom_hline(yintercept = c(-1.96/sqrt(length(ret_vector)), 1.96/sqrt(length(ret_vector))), 
             linetype = "dashed", color = "blue") +
  theme_minimal() +
  labs(title = "ACF of Squared Returns", x = "Lag", y = "Autocorrelation")
save_plot(p5, "fig_05_acf_sq_GSPC.png", width = 6, height = 6)

print("✅ Phase 2 EDA Complete: Summary table and 5 figures generated and saved.")