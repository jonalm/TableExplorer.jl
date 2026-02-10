using Test
using TableExplorer
using DataFrames

# Create various column types
df = DataFrame(
    cat = ["A", "B", "C"],
    bool = [true, false, true],
    num = [1, 2, 3],
    text = ["foo", "bar", "baz"]
)

html = TableExplorer.table_html(df,
    :cat => ColumnCategorical(),
    :num => ColumnNumeric(),
    :text => ColumnText()
)

@test html isa String

# CRITICAL: Ensure "select" is never used as headerFilter type
# (Tabulator 6.3 replaced "select" with "list")
@test !occursin("\"headerFilter\": \"select\"", html)
@test !occursin("\"headerFilter\":\"select\"", html)
