# ==========================================
# 01_get_data_returns.R - Download and Process ^GSPC
# ==========================================

# 1. Load our established environment
source("03_code/R/00_setup.R")

# 2. Define our paper's exact parameters
ticker <- "^GSPC"
start_date <- "2014-01-01"
end_date <- "2026-02-01"

# 3. Pull data from Yahoo Finance
message("Downloading data for ", ticker, "...")
getSymbols(ticker, from = start_date, to = end_date, warnings = FALSE, auto.assign = TRUE)

# 4. Clean and calculate log returns in percent
# getSymbols creates an object named 'GSPC' in the environment automatically
prices <- GSPC[, "GSPC.Adjusted"]

# CalculateReturns is from the PerformanceAnalytics package
# We use na.omit because the first return calculation always creates an NA
returns <- na.omit(100 * CalculateReturns(prices, method = "log"))

# Standardize column names
colnames(prices) <- "Price"
colnames(returns) <- "Log_Return_Pct"

# 5. Convert to standard data frames and save
prices_df <- data.frame(Date = index(prices), coredata(prices))
returns_df <- data.frame(Date = index(returns), coredata(returns))

write.csv(prices_df, "02_data/raw/prices_GSPC_2014_2026.csv", row.names = FALSE)
write.csv(returns_df, "02_data/processed/returns_GSPC_2014_2026.csv", row.names = FALSE)

print("✅ Phase 1 Complete: Data downloaded, returns calculated, and CSVs saved.")