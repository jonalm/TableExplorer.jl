using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    value = [1.5, 2.5, 3.5],
    status = ["Active", "Inactive", "Pending"]
)

# Test with column type specifications
html = table_html(df,
    :value => ColumnNumeric(decimal_places=2),
    :status => ColumnCategorical()
)
@test html isa String
@test occursin("toFixed(2)", html)
