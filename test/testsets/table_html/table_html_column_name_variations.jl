using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Test with various column name types
df = DataFrame(
    Symbol("normal") => [1, 2],
    Symbol("with space") => [3, 4],
    Symbol("with-dash") => [5, 6],
    Symbol("with_underscore") => [7, 8]
)

html = table_html(df)
@test html isa String
@test occursin("normal", html)
@test occursin("with space", html)
@test occursin("with-dash", html)
@test occursin("with_underscore", html)
