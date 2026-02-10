using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Active", missing, nothing, "Inactive"]
)

html = TableExplorer.table_html(df,
    :status => ColumnCategorical()
)

@test html isa String

# Verify only ONE (null) option appears, not separate (missing) and (nothing)
@test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)
@test !occursin("\"label\":\"(missing)\"", html) && !occursin("\"label\": \"(missing)\"", html)
@test !occursin("\"label\":\"(nothing)\"", html) && !occursin("\"label\": \"(nothing)\"", html)

# Count occurrences of (null) - should be exactly 1
null_count = length(collect(eachmatch(r"\"label\":\s*\"\(null\)\"", html)))
@test null_count == 1

# Verify list filter is used
@test occursin("\"headerFilter\": \"list\"", html)
