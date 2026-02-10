using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(a = [1, 2], b = ["x", "y"])

# Test with String keys
html1 = table_html(df, "a" => ColumnNumeric())
@test html1 isa String

# Test with Symbol keys
html2 = table_html(df, :b => ColumnText())
@test html2 isa String

# Test mixed
html3 = table_html(df,
    "a" => ColumnNumeric(),
    :b => ColumnText()
)
@test html3 isa String
