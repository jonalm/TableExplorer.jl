using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Active", "Inactive", "Active"],
    flag = [true, false, true],
    score = [1.5, 2.5, 3.5]
)

html = TableExplorer.table_html(df,
    :status => ColumnCategorical(),
    :score => ColumnNumeric(decimal_places=2)
)

@test html isa String

# Count occurrences of list filters (should be 2: status and flag)
list_filter_count = length(collect(eachmatch(r"\"headerFilter\":\s*\"list\"", html)))
@test list_filter_count == 2

# Numeric column should have input filter
@test occursin("\"headerFilter\": \"input\"", html)
