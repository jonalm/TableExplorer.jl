using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Test with a moderately large table
n = 1000
df = DataFrame(
    id = 1:n,
    category = rand(["A", "B", "C", "D"], n),
    value = rand(n) .* 100,
    flag = rand(Bool, n)
)

html = table_html(df)
@test html isa String
@test occursin("/ 1000 |", html)  # 1000 total rows

# Test that all data is embedded (spot check)
@test occursin("id", html)
@test occursin("category", html)
