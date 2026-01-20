using TableExplorer
using DataFrames
using Random

# Set seed for reproducibility
Random.seed!(42)
num_rows = 100
# Create sample data with various numeric columns suitable for heatmap visualization
df = DataFrame(
    product = ["Product $i" for i in 1:num_rows],

    # Temperature data (will use auto min/max)
    temperature = randn(num_rows) .* 10 .+ 20,

    # Sales score (0-100 range, explicit range)
    sales_score = rand(num_rows) .* 100,

    # Performance metric (with some special values)
    performance = [rand(num_rows-2) .* 10; NaN; Inf],

    # Profit margin percentage
    profit_margin = randn(num_rows) .* 5 .+ 15,

    # Customer satisfaction (1-5 scale)
    satisfaction = rand(1:5, num_rows) .+ randn(num_rows) .* 0.3,

    # Regular categorical column for contrast
    category = rand(["Electronics", "Clothing", "Food", "Books"], num_rows),

    # Regular numeric column (showing values as text)
    quantity = rand(10:1000, num_rows)

)

# Explore table with multiple heatmap columns demonstrating different features
explore_table(df,
    # Auto-detect min/max from data
    :temperature => ColumnHeatmap(),

    # Explicit range (0-100)
    :sales_score => ColumnHeatmap(min_value=0.0, max_value=100.0),

    # Heatmap showing special values (NaN, Inf as gray)
    :performance => ColumnHeatmap(),

    # Another auto-range heatmap
    :profit_margin => ColumnHeatmap(),

    # Heatmap with custom alignment (not visible since no text)
    :satisfaction => ColumnHeatmap(alignment=:center),

    # Regular categorical for comparison
    :category => ColumnCategorical(),

    # Regular numeric showing actual values
    :quantity => ColumnNumeric(decimal_places=0);

    auto_categorical_threshold=100
)
