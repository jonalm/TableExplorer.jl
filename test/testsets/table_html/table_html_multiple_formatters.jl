using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    a = [1.5, 2.5],
    b = [true, false],
    c = ["X", "Y"]
)

html = table_html(df,
    :a => ColumnNumeric(decimal_places=3),
    :c => ColumnCategorical(color_map=Dict("X" => "#aabbcc", "Y" => "#ddeeff"))
)

@test occursin("toFixed(3)", html)
@test occursin("#aabbcc", html)
@test occursin("#ddeeff", html)
