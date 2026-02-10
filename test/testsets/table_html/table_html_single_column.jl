using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(value = [1, 2, 3, 4, 5])

html = table_html(df)
@test html isa String
@test occursin("/ 5 |", html)  # 5 total rows
@test occursin("Columns:</strong> 1", html)
