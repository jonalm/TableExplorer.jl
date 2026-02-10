using Test
using TableExplorer
using DataFrames

df = DataFrame(x = [1, 2, 3], y = ["a", "b", "c"])

# Test explicit type (Symbol key)
col_types = Dict(:x => ColumnText())
result = TableExplorer.get_or_detect_column_type(df, :x, col_types, 10)
@test result isa ColumnText

# Test auto-detection
result = TableExplorer.get_or_detect_column_type(df, :y, col_types, 10)
@test result isa ColumnCategorical

# Test with String key in lookup
result = TableExplorer.get_or_detect_column_type(df, "x", col_types, 10)
@test result isa ColumnText
