using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    a = [1, 2, 3],
    b = ["x", "y", "z"],
    c = [true, false, true]
)

# Specify only one column, others should auto-detect
html = table_html(df,
    :a => ColumnNumeric(decimal_places=3)
)

@test html isa String
@test occursin("toFixed(3)", html)
# b and c should be auto-detected
@test occursin("\"b\"", html)
@test occursin("\"c\"", html)
