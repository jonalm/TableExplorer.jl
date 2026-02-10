using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    category = repeat(["A", "B", "C"], 5)
)

# Test with threshold
html1 = table_html(df, auto_categorical_threshold=10)
@test html1 isa String

# Test with threshold disabled
html2 = table_html(df, auto_categorical_threshold=nothing)
@test html2 isa String

# Both should generate valid HTML
@test !isempty(html1)
@test !isempty(html2)
