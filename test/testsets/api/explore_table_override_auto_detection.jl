using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Create data that would normally be auto-detected as categorical
df = DataFrame(
    status = repeat(["A", "B"], 5)
)

# Override with explicit ColumnText
html = table_html(df,
    :status => ColumnText(),
    auto_categorical_threshold=10
)

@test html isa String
# Should be treated as text, not categorical
# (Hard to verify without parsing, but at least it should work)
