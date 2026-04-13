# ==========================================
# 03_garch_var.R - GARCH-t Fit & Rolling VaR
# ==========================================

# 1. Load setup and required libraries
source("03_code/R/00_setup.R")
library(zoo) # Required for rolling historical/normal calculations

# Load the processed returns
returns_df <- read.csv("02_data/processed/returns_GSPC_2014_2026.csv")
returns_df$Date <- as.Date(returns_df$Date)

# Convert to an xts time-series object (required by rugarch for clean date handling)
ret_xts <- xts(returns_df$Log_Return_Pct, order.by = returns_df$Date)

# Ensure our model_objects folder exists
if(!dir.exists("04_outputs/model_objects")) dir.create("04_outputs/model_objects", recursive = TRUE)

# ==========================================
# 2. Fit GARCH(1,1) with Student-t Innovations
# ==========================================
# Define the specification: ARMA(0,0) mean, GARCH(1,1) variance, Student-t distribution
garch_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)

message("Fitting GARCH model on full dataset...")
# We use solver = "hybrid" to ensure convergence
garch_fit <- ugarchfit(spec = garch_spec, data = ret_xts, solver = "hybrid")

# Save the full model object for Phase 3 (where we extract residuals for EVT)
saveRDS(garch_fit, "04_outputs/model_objects/garch_t_GSPC.rds")

# ==========================================
# 3. Export Parameter Table
# ==========================================
fit_coefs <- garch_fit@fit$matcoef

# Using column numbers instead of names to avoid spacing errors
params_df <- data.frame(
  Parameter = rownames(fit_coefs),
  Estimate = round(fit_coefs[, 1], 6),     # Column 1 is Estimate
  Std_Error = round(fit_coefs[, 2], 6),    # Column 2 is Std. Error
  t_value = round(fit_coefs[, 3], 4),      # Column 3 is t value
  p_value = round(fit_coefs[, 4], 4)       # Column 4 is p-value
)

save_table(params_df, "tab_02_garch_params_GSPC.csv")

# ==========================================
# 4. Plot Conditional Volatility
# ==========================================
volatility <- sigma(garch_fit)
vol_df <- data.frame(Date = index(volatility), Volatility = coredata(volatility))

p6 <- ggplot(vol_df, aes(x = Date, y = Volatility)) +
  geom_line(color = "darkorange", linewidth = 0.5) +
  theme_minimal() +
  labs(title = "GARCH(1,1)-t Conditional Volatility", x = "Date", y = "Volatility (%)")
save_plot(p6, "fig_06_garch_vol_GSPC.png", width = 10, height = 5)

# ==========================================
# 5. Compute Rolling VaR (Historical, Normal, GARCH-t)
# ==========================================
message("Computing rolling VaR (this will take 1-3 minutes, please wait)...")

# We use a 1000-day rolling window (roughly 4 years of trading data)
window_size <- 1000

# A. Rolling Historical and Normal VaR (Align = right ensures we only use past data)
roll_hs_99 <- rollapply(ret_xts, width = window_size, FUN = function(x) quantile(x, 0.01), align = "right", fill = NA)
roll_norm_99 <- rollapply(ret_xts, width = window_size, FUN = function(x) qnorm(0.01, mean(x), sd(x)), align = "right", fill = NA)

# B. Rolling GARCH-t VaR using ugarchroll
# Refitting every 50 days speeds up computation while maintaining out-of-sample realism
garch_roll <- ugarchroll(
  garch_spec,
  data = ret_xts,
  n.start = window_size,
  refit.every = 50,
  refit.window = "moving",
  solver = "hybrid",
  calculate.VaR = TRUE,
  VaR.alpha = c(0.01, 0.05)
)

# Save rolling objects to use in the final backtesting script
saveRDS(garch_roll, "04_outputs/model_objects/garch_roll_GSPC.rds")

baseline_var_df <- data.frame(
  Date = index(ret_xts),
  Return = coredata(ret_xts),
  VaR_HS_99 = coredata(roll_hs_99),
  VaR_Norm_99 = coredata(roll_norm_99)
)
write.csv(baseline_var_df, "04_outputs/model_objects/baseline_var_GSPC.csv", row.names = FALSE)

print("✅ Phase 2 Volatility Modeling Complete: GARCH fitted, volatility plotted, and rolling VaR computed.")