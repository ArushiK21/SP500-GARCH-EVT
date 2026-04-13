# ==========================================
# 00_setup.R - Packages and Helpers
# ==========================================

# 1. Package Installation and Loading
# We use 'pacman' because it automatically checks if a package is installed. 
# If it is missing, it installs it; if it is there, it just loads it.
if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  tidyverse,             # Data manipulation and ggplot2
  lubridate,             # Date handling
  quantmod,              # Financial data download (Yahoo Finance)
  PerformanceAnalytics,  # Financial returns and summary stats
  moments,               # Skewness and kurtosis
  tseries,               # Time series tests (ADF, etc.)
  rugarch,               # GARCH modeling
  evir                   # Extreme Value Theory (POT/GPD)
)

# 2. Ensure Output Directories Exist (Posit Cloud safety net)
if(!dir.exists("04_outputs/figures")) dir.create("04_outputs/figures", recursive = TRUE)
if(!dir.exists("04_outputs/tables")) dir.create("04_outputs/tables", recursive = TRUE)

# 3. Helper Function: Save Plots Consistently
# This guarantees every chart you make is formatted identically for your paper.
save_plot <- function(p, filename, width = 8, height = 5) {
  filepath <- file.path("04_outputs", "figures", filename)
  ggplot2::ggsave(filename = filepath, plot = p, width = width, height = height, bg = "white")
  message("✅ Saved plot to: ", filepath)
}

# 4. Helper Function: Save Tables Consistently
# This strips out messy row names so your tables look clean in the final PDF.
save_table <- function(df, filename) {
  filepath <- file.path("04_outputs", "tables", filename)
  write.csv(df, file = filepath, row.names = FALSE)
  message("✅ Saved table to: ", filepath)
}

print("🚀 Setup complete. Packages loaded and helper functions are ready.")