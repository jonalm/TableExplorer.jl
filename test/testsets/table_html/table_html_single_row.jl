using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(x = [42], y = ["test"])

html = table_html(df)
@test html isa String
@test occursin("/ 1 |", html)  # 1 total row
@test occursin("42", html)
@test occursin("test", html)
