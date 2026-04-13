# ==========================================
# 05_backtest.R - VaR Backtesting & Kupiec Test
# ==========================================

# 1. Load setup
source("03_code/R/00_setup.R")

# 2. Load all models and data
returns_df <- read.csv("02_data/processed/returns_GSPC_2014_2026.csv")
ret_xts <- xts(returns_df$Log_Return_Pct, order.by = as.Date(returns_df$Date))

baseline_var <- read.csv("04_outputs/model_objects/baseline_var_GSPC.csv")
baseline_var$Date <- as.Date(baseline_var$Date)

garch_roll <- readRDS("04_outputs/model_objects/garch_roll_GSPC.rds")
gpd_fit <- readRDS("04_outputs/model_objects/gpd_fit_GSPC.rds")
threshold <- readRDS("04_outputs/model_objects/gpd_threshold_GSPC.rds")

# ==========================================
# 3. Align Data and Calculate EVT VaR
# ==========================================
message("Compiling rolling VaR forecasts...")
garch_var_df <- as.data.frame(garch_roll, which = "VaR")
garch_density <- as.data.frame(garch_roll, which = "density")

aligned_dates <- as.Date(rownames(garch_var_df))
actual_returns <- garch_var_df$realized

# Extract 99% GARCH-t VaR
var_garch_99 <- garch_var_df$`alpha(1%)`

# Calculate the standardized EVT Quantile (99%)
n_total <- length(ret_xts)
n_u <- gpd_fit$n.exceed
xi <- as.numeric(gpd_fit$par.ests["xi"])
beta <- as.numeric(gpd_fit$par.ests["beta"])

# EVT Quantile Formula (McNeil & Frey approach)
evt_quant <- threshold + (beta / xi) * ( ((n_total / n_u) * 0.01)^(-xi) - 1 )

# Dynamically scale EVT VaR using rolling GARCH mean and volatility
# We subtract because evt_quant represents a positive loss magnitude
var_evt_99 <- garch_density$Mu - (garch_density$Sigma * evt_quant)

# Merge all forecasts into one master dataframe
backtest_data <- data.frame(
  Date = aligned_dates,
  Actual = actual_returns,
  VaR_GARCH = var_garch_99,
  VaR_EVT = var_evt_99
)
backtest_data <- merge(backtest_data, baseline_var[, c("Date", "VaR_HS_99", "VaR_Norm_99")], by = "Date", all.x = TRUE)
backtest_data <- na.omit(backtest_data)

# ==========================================
# 4. Kupiec Test (Proportion of Failures)
# ==========================================
message("Running Kupiec tests...")

# Helper function to run the Kupiec Likelihood Ratio Test safely
run_kupiec <- function(actual, var_forecast, alpha = 0.01) {
  # Count violations (when actual return is more negative than VaR)
  violations <- sum(actual < var_forecast)
  N <- length(actual)
  breach_rate <- violations / N
  
  # Kupiec POF Test Statistic
  if(violations == 0) {
    p_value <- NA # Model is too conservative
  } else {
    LR <- -2 * ( (N - violations)*log(1 - alpha) + violations*log(alpha) - 
                   (N - violations)*log(1 - breach_rate) - violations*log(breach_rate) )
    p_value <- 1 - pchisq(LR, df = 1)
  }
  
  return(c(Violations = violations, Breach_Rate = round(breach_rate, 4), Kupiec_p = round(p_value, 4)))
}

res_hs <- run_kupiec(backtest_data$Actual, backtest_data$VaR_HS_99)
res_norm <- run_kupiec(backtest_data$Actual, backtest_data$VaR_Norm_99)
res_garch <- run_kupiec(backtest_data$Actual, backtest_data$VaR_GARCH)
res_evt <- run_kupiec(backtest_data$Actual, backtest_data$VaR_EVT)

tab_04 <- data.frame(
  Model = c("Historical", "Normal", "GARCH-t", "GARCH-EVT"),
  VaR_Level = "99%",
  Violations = c(res_hs[1], res_norm[1], res_garch[1], res_evt[1]),
  Actual_Breach_Rate = c(res_hs[2], res_norm[2], res_garch[2], res_evt[2]),
  Kupiec_p_value = c(res_hs[3], res_norm[3], res_garch[3], res_evt[3])
)
save_table(tab_04, "tab_04_backtest_GSPC.csv")

# ==========================================
# 5. Final VaR Overlay Plot
# ==========================================
p8 <- ggplot(backtest_data, aes(x = Date)) +
  geom_line(aes(y = Actual), color = "gray80", alpha = 0.7) +
  geom_line(aes(y = VaR_GARCH, color = "GARCH-t VaR"), linewidth = 0.6) +
  geom_line(aes(y = VaR_EVT, color = "GARCH-EVT VaR"), linewidth = 0.6) +
  scale_color_manual(values = c("GARCH-t VaR" = "darkorange", "GARCH-EVT VaR" = "darkred")) +
  theme_minimal() +
  labs(title = "99% VaR Overlay: S&P 500 Crashes vs. Forecasts", x = "Date", y = "Log Return (%)", color = "Model") +
  theme(legend.position = "bottom")
save_plot(p8, "fig_08_var_overlay_99_GSPC.png", width = 10, height = 5)

print("✅ Phase 4 Complete: Backtesting finished, Kupiec test executed, and overlay plot saved.")