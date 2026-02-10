using Test
using TableExplorer
using DataFrames

# Test with auto min/max calculation
df = DataFrame(value = [1.0, 2.0, 3.0, 4.0, 5.0])
col = ColumnHeatmap()
result = TableExplorer.create_formatter(col, df, :value)
@test result isa String
@test occursin("var minVal = 1.0", result)
@test occursin("var maxVal = 5.0", result)
@test occursin("palette", result)
@test occursin("return '';", result)  # Should return empty string

# Test with explicit min/max
col_explicit = ColumnHeatmap(min_value=0.0, max_value=10.0)
result = TableExplorer.create_formatter(col_explicit, df, :value)
@test occursin("var minVal = 0.0", result)
@test occursin("var maxVal = 10.0", result)

# Test with missing/nothing values
df_missing = DataFrame(value = [1.0, missing, nothing, 3.0])
result_missing = TableExplorer.create_formatter(col, df_missing, :value)
@test occursin("var minVal = 1.0", result_missing)
@test occursin("var maxVal = 3.0", result_missing)

# Test with NaN/Inf values - should be excluded from min/max
df_special = DataFrame(value = [1.0, NaN, Inf, -Inf, 5.0])
result_special = TableExplorer.create_formatter(col, df_special, :value)
@test occursin("var minVal = 1.0", result_special)
@test occursin("var maxVal = 5.0", result_special)

# Test min==max edge case
df_same = DataFrame(value = [2.0, 2.0, 2.0])
result_same = TableExplorer.create_formatter(col, df_same, :value)
@test occursin("var minVal = 2.0", result_same)
@test occursin("var maxVal = 3.0", result_same)  # Should be min + 1

# Test empty column (all missing/NaN)
df_empty = DataFrame(value = [missing, NaN, nothing])
result_empty = TableExplorer.create_formatter(col, df_empty, :value)
@test occursin("var minVal = 0.0", result_empty)  # Default min
@test occursin("var maxVal = 1.0", result_empty)  # Default max

# Test single value column
df_single = DataFrame(value = [3.5])
result_single = TableExplorer.create_formatter(col, df_single, :value)
@test occursin("var minVal = 3.5", result_single)
@test occursin("var maxVal = 4.5", result_single)  # min + 1

# Test that palette is embedded
custom_palette = ["#ff0000", "#00ff00", "#0000ff"]
col_palette = ColumnHeatmap(palette=custom_palette)
result_palette = TableExplorer.create_formatter(col_palette, df, :value)
@test occursin("#ff0000", result_palette)
@test occursin("#00ff00", result_palette)
@test occursin("#0000ff", result_palette)
