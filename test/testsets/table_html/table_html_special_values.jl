using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    normal = [1.0, 2.0, 3.0],
    with_nan = [1.0, NaN, 3.0],
    with_inf = [1.0, Inf, -Inf],
    with_missing = [1, missing, 3]
)

html = table_html(df)
@test html isa String

# Verify HTML is generated successfully even with special values
@test occursin("normal", html)
@test occursin("with_nan", html)
@test occursin("with_inf", html)
@test occursin("with_missing", html)
