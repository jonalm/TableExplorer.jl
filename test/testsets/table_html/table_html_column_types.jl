using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(
    text_col = ["A", "B", "C"],
    num_col = [1.5, 2.5, 3.5],
    cat_col = ["X", "Y", "X"],
    bool_col = [true, false, true]
)

html = table_html(df,
    :text_col => ColumnText(search_type=:exact),
    :num_col => ColumnNumeric(decimal_places=2),
    :cat_col => ColumnCategorical(color_map=Dict("X" => "#ff0000", "Y" => "#00ff00")),
)

@test html isa String
@test !isempty(html)

# Verify column-specific configurations are present
@test occursin("toFixed(2)", html)  # Numeric formatter
@test occursin("#ff0000", html)  # Categorical colors
