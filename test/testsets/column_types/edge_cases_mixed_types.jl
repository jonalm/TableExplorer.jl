using Test
using TableExplorer
using DataFrames

# Test with Union types
df = DataFrame(value = Union{Int, Missing}[1, missing, 3])
result = TableExplorer.auto_detect_column_type(df, :value)
@test result isa ColumnNumeric

# Test with Union{String, Missing}
df_str = DataFrame(name = Union{String, Missing}["Alice", missing, "Bob"])
result = TableExplorer.auto_detect_column_type(df_str, :name, auto_categorical_threshold=5)
@test result isa ColumnCategorical
