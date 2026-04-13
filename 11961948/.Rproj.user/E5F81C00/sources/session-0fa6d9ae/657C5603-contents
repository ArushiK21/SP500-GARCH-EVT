# ==========================================
# 04_evt_pot.R - Extreme Value Theory (POT/GPD)
# ==========================================

# 1. Load setup and helpers
source("03_code/R/00_setup.R")

# Load the fitted GARCH model and processed returns
garch_fit <- readRDS("04_outputs/model_objects/garch_t_GSPC.rds")
returns_df <- read.csv("02_data/processed/returns_GSPC_2014_2026.csv")

# ==========================================
# 2. Extract Standardized Residuals
# ==========================================
# EVT requires i.i.d. data. We use the standardized residuals from the GARCH model.
# We multiply by -1 because the 'evir' package models the right tail (maxima), 
# but we are analyzing large negative returns (left tail risk).
std_residuals <- -1 * as.numeric(residuals(garch_fit, standardize = TRUE))

# ==========================================
# 3. Mean Excess Plot
# ==========================================
message("Generating Mean Excess Plot...")
# 'evir' uses base R plotting, so we use png() instead of ggsave()
png("04_outputs/figures/fig_07_mean_excess_GSPC.png", width = 800, height = 500)
evir::meplot(std_residuals)
title(main = "Mean Excess Plot of Standardized Losses")
dev.off()

# ==========================================
# 4. Threshold Selection and GPD Fit
# ==========================================
# Fixing threshold at the 95th percentile to ensure enough exceedances
threshold <- quantile(std_residuals, 0.95)
message("Selected Threshold (95th Percentile): ", round(threshold, 4))

# Fit the Generalized Pareto Distribution (GPD)
gpd_fit <- evir::gpd(std_residuals, threshold = threshold)

# ==========================================
# 5. Export EVT Parameter Table
# ==========================================
# Extracting shape (xi) and scale (beta) parameters
gpd_params <- data.frame(
  Parameter = c("Threshold", "Exceedances", "Shape (xi)", "Scale (beta)"),
  Estimate = c(
    round(threshold, 4),
    gpd_fit$n.exceed,
    round(gpd_fit$par.ests["xi"], 6),
    round(gpd_fit$par.ests["beta"], 6)
  ),
  Std_Error = c(
    NA, # Threshold is fixed
    NA, # Exceedances is a count
    round(gpd_fit$par.ses["xi"], 6),
    round(gpd_fit$par.ses["beta"], 6)
  )
)

save_table(gpd_params, "tab_03_evt_params_GSPC.csv")

# Save the EVT objects for the final backtesting script
saveRDS(gpd_fit, "04_outputs/model_objects/gpd_fit_GSPC.rds")
saveRDS(threshold, "04_outputs/model_objects/gpd_threshold_GSPC.rds")

print("✅ Phase 3 Complete: EVT residuals extracted, GPD fitted, and params saved.")