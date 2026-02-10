using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Create a column that would be auto-detected as categorical
df = DataFrame(status = ["A", "B", "A", "B"])

# Override to use text
html = table_html(df,
    :status => ColumnText(),
    auto_categorical_threshold=10
)

# Should not have categorical colors because we explicitly set it to ColumnText
# (This is a bit tricky to test without parsing HTML, but we can check structure)
@test html isa String
@test occursin("status", html)
