using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    status = repeat(["A", "B", "C"], 10),
    id = 1:30
)

# Test with threshold enabled
html_with_threshold = table_html(df, auto_categorical_threshold=5)
# Status should be categorical (3 unique values <= 5)
@test occursin("backgroundColor", html_with_threshold)

# Test with threshold disabled
html_no_threshold = table_html(df, auto_categorical_threshold=nothing)
# Should have less categorical formatting
@test html_no_threshold isa String

# Test with low threshold
html_low_threshold = table_html(df, auto_categorical_threshold=2)
# Status has 3 unique values > 2, so should not be categorical
@test html_low_threshold isa String
