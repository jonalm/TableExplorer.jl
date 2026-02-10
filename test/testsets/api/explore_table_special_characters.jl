using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    text = ["<html>", "&nbsp;", "quote\"test", "apostrophe's"]
)

html = table_html(df)
@test html isa String
# The HTML should handle special characters properly
@test !isempty(html)
