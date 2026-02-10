using Test
using TableExplorer
using DataFrames

# Test with only normal numbers (no special values)
df_normal = DataFrame(value = [1.0, 2.0, 3.0])
html_normal = TableExplorer.table_html(df_normal,
    :value => ColumnNumeric(search_type=:dropdown)
)

@test occursin("\"label\":\"numerical\"", html_normal) || occursin("\"label\": \"numerical\"", html_normal)
@test !occursin("\"label\":\"NaN\"", html_normal) && !occursin("\"label\": \"NaN\"", html_normal)
@test !occursin("\"label\":\"Infinity\"", html_normal) && !occursin("\"label\": \"Infinity\"", html_normal)
@test !occursin("\"label\":\"(null)\"", html_normal) && !occursin("\"label\": \"(null)\"", html_normal)

# Test with only NaN (no other special values)
df_nan_only = DataFrame(value = [NaN, NaN])
html_nan_only = TableExplorer.table_html(df_nan_only,
    :value => ColumnNumeric(search_type=:dropdown)
)

@test occursin("\"label\":\"NaN\"", html_nan_only) || occursin("\"label\": \"NaN\"", html_nan_only)
@test !occursin("\"label\":\"numerical\"", html_nan_only) && !occursin("\"label\": \"numerical\"", html_nan_only)
@test !occursin("\"label\":\"Infinity\"", html_nan_only) && !occursin("\"label\": \"Infinity\"", html_nan_only)
