using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Empty table
df_empty = DataFrame(a = Int[], b = String[])
html_empty = table_html(df_empty)
@test html_empty isa String

# Single row
df_single = DataFrame(x = [1])
html_single = table_html(df_single)
@test html_single isa String

# Large table
df_large = DataFrame(
    id = 1:1000,
    value = rand(1000)
)
html_large = table_html(df_large)
@test html_large isa String
