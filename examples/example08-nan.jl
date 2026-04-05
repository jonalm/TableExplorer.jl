using TableExplorer
using DataFrames
using Random

# Set seed for rea with various numeric columns suitable for heatmap visualization
df = DataFrame(
    number = [3.1, NaN, missing, nothing, 2.1],
)

# Explore table with multiple heatmap columns demonstrating different features
explore_table(df,)
