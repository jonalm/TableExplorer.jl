using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Active", missing, "Inactive"]
)

html = TableExplorer.table_html(df,
    :status => ColumnCategorical()
)

@test html isa String

# Verify dropdown includes (null) label (not (missing))
@test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)

# Verify list filter is used
@test occursin("\"headerFilter\": \"list\"", html)
