using Test
using TableExplorer
using DataFrames

# Create DataFrame with categorical column (few unique values)
df = DataFrame(
    category = ["A", "B", "A", "B", "C"],
    value = [1, 2, 3, 4, 5]
)

# Use auto-detection
html = TableExplorer.table_html(df, auto_categorical_threshold=5)

@test html isa String

# Category column should auto-detect as categorical and get list filter
@test occursin("\"headerFilter\": \"list\"", html)

# Verify dropdown values for auto-detected categorical
@test occursin("\"label\":\"A\"", html) || occursin("\"label\": \"A\"", html)
@test occursin("\"label\":\"B\"", html) || occursin("\"label\": \"B\"", html)
@test occursin("\"label\":\"C\"", html) || occursin("\"label\": \"C\"", html)
