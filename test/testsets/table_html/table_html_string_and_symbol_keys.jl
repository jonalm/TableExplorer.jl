using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(a = [1, 2], b = [3, 4])

# Test with String keys
html1 = table_html(df, "a" => ColumnNumeric(decimal_places=1))
@test occursin("toFixed(1)", html1)

# Test with Symbol keys
html2 = table_html(df, :b => ColumnNumeric(decimal_places=2))
@test occursin("toFixed(2)", html2)

# Test mixed
html3 = table_html(df,
    "a" => ColumnNumeric(decimal_places=1),
    :b => ColumnNumeric(decimal_places=2)
)
@test occursin("toFixed(1)", html3)
@test occursin("toFixed(2)", html3)
