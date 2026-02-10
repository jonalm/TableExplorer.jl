using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(a = Int[], b = String[])

html = table_html(df)
@test html isa String
@test occursin("Rows:", html)
@test occursin("Columns:</strong> 2", html)
