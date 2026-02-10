using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Pass", "Fail", "Pass"],
    value = [1, 2, 3]
)

# Generate HTML with custom boolean labels
html = TableExplorer.table_html(df,
    :status => ColumnCategorical(
        color_map=Dict("Pass" => "#00ff00", "Fail" => "#ff0000")
    )
)

@test html isa String

# Verify dropdown is configured
@test occursin("\"headerFilter\": \"list\"", html)

# Verify the custom colors are in the formatter
@test occursin("#00ff00", html)
@test occursin("#ff0000", html)
