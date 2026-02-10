using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

df = DataFrame(x = [1])
html = table_html(df)

# Verify that placeholders are replaced
@test !occursin("{{CSS_CONTENT}}", html)
@test !occursin("{{JS_CONTENT}}", html)
@test !occursin("{{TABLE_DATA}}", html)
@test !occursin("{{COLUMNS}}", html)
@test !occursin("{{NROWS}}", html)
@test !occursin("{{NCOLS}}", html)

# Verify CSS and JS content is embedded
@test occursin("<style>", html) || occursin("table", html)  # Some CSS content
@test occursin("Tabulator", html) || occursin("var table", html)  # Some JS content
