using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames
using Tables

# Test with NamedTuple
nt = (a = [1, 2, 3], b = ["x", "y", "z"])
html_nt = table_html(nt)
@test html_nt isa String
@test occursin("\"x\"", html_nt)

# Test with DataFrame (already tested above)
df = DataFrame(c = [1, 2], d = [3, 4])
html_df = table_html(df)
@test html_df isa String

# Test that non-table throws error
@test_throws ArgumentError table_html([1, 2, 3])
