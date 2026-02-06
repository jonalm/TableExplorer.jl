using TableExplorer
using DataFrames
using Random

# Set seed for rea with various numeric columns suitable for heatmap visualization
df = DataFrame(
    product = [true, false, missing],
)

# Explore table with multiple heatmap columns demonstrating different features
explore_table(df,
)
