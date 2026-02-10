using Test
using TableExplorer
using DataFrames

# Test with explicit decimal places
df = DataFrame(value = [1.23, 4.56])
col = ColumnNumeric(decimal_places=2)
result = TableExplorer.create_formatter(col, df, :value)
@test result isa String
@test occursin("toFixed(2)", result)

# Test with auto-detection for floats
col_auto = ColumnNumeric()
result = TableExplorer.create_formatter(col_auto, df, :value)
@test occursin("toFixed(2)", result)

# Test with integers - should use String() not toLocaleString()
df_int = DataFrame(count = [1, 2, 3])
result_int = TableExplorer.create_formatter(col_auto, df_int, :count)
@test occursin("String(val)", result_int)
@test !occursin("toLocaleString()", result_int)

# Test with Union{Missing, Float64} - should use toFixed() for consistent decimal separator
df_missing = DataFrame(value = [1.23, missing, 4.56])
result_missing = TableExplorer.create_formatter(col_auto, df_missing, :value)
@test occursin("toFixed", result_missing)
@test !occursin("toLocaleString()", result_missing)
