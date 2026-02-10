using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    str = ["test", "data"],
    num = [1, 2],
    bool = [true, false]
)

html = table_html(df)

# Verify valid JSON structure is present
# (We can't easily parse it from the HTML, but we can check for structure)
@test occursin("\"str\"", html)
@test occursin("\"num\"", html)
@test occursin("\"bool\"", html)
