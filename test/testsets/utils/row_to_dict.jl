using Test
using TableExplorer
using DataFrames
using Tables

df = DataFrame(
    a = [1, 2, 3],
    b = ["x", "y", "z"],
    c = [1.5, 2.5, 3.5]
)

# Test normal row
row = Tables.rows(df)[1]
colnames = [:a, :b, :c]
result = TableExplorer.row_to_dict(row, colnames)
@test result isa Dict{String, Any}
@test result["a"] == 1
@test result["b"] == "x"
@test result["c"] == 1.5

# Test with NaN - should be converted to string "NaN"
df_nan = DataFrame(a = [NaN, 1.0], b = [2.0, 3.0])
row_nan = Tables.rows(df_nan)[1]
result = TableExplorer.row_to_dict(row_nan, [:a, :b])
@test result["a"] == "NaN"
@test result["b"] == 2.0

# Test with Inf - should be converted to string "Infinity"
df_inf = DataFrame(a = [Inf, 1.0], b = [2.0, -Inf])
row_inf = Tables.rows(df_inf)[1]
result = TableExplorer.row_to_dict(row_inf, [:a, :b])
@test result["a"] == "Infinity"
@test result["b"] == 2.0

# Test with -Inf - should be converted to string "-Infinity"
row_inf2 = Tables.rows(df_inf)[2]
result2 = TableExplorer.row_to_dict(row_inf2, [:a, :b])
@test result2["a"] == 1.0
@test result2["b"] == "-Infinity"

# Test with missing values
df_missing = DataFrame(a = [missing, 1], b = [2, missing])
row_missing = Tables.rows(df_missing)[1]
result = TableExplorer.row_to_dict(row_missing, [:a, :b])
@test ismissing(result["a"])
@test result["b"] == 2
