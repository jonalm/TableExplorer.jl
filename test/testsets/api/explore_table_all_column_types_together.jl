using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames
using Dates

df = DataFrame(
    text_col = ["A", "B", "C"],
    numeric_col = [1.5, 2.5, 3.5],
    categorical_col = ["X", "Y", "X"],
    boolean_col = [true, false, true],
    date_col = [Date(2024, 1, 1), Date(2024, 1, 2), Date(2024, 1, 3)]
)

html = table_html(df,
    :text_col => ColumnText(search_type=:exact),
    :numeric_col => ColumnNumeric(decimal_places=2),
    :categorical_col => ColumnCategorical(
        color_map=Dict("X" => "#ff0000", "Y" => "#00ff00")
    ),
    :date_col => ColumnDateTime(format="yyyy-mm-dd")
)

@test html isa String
@test !isempty(html)

# Verify each column type configuration is present
@test occursin("toFixed(2)", html)
@test occursin("#ff0000", html)
