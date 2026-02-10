using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Active", "Inactive", "Pending"],
    value = [1, 2, 3]
)

# Generate HTML with categorical column
html = TableExplorer.table_html(df,
    :status => ColumnCategorical()
)

@test html isa String
@test !isempty(html)

# Verify it's valid HTML
@test occursin("<!DOCTYPE html>", html)
@test occursin("<html", html)
@test occursin("</html>", html)

# Verify Tabulator.js is included
@test occursin("tabulator", html)

# Extract columns configuration from HTML
columns_start = findfirst("const columns = ", html)
@test !isnothing(columns_start)

# Verify the status column has list filter (not select)
@test occursin("\"headerFilter\": \"list\"", html)
@test !occursin("\"headerFilter\": \"select\"", html)

# Verify headerFilterParams is present
@test occursin("\"headerFilterParams\"", html)

# Verify the values are present in the dropdown
@test occursin("\"label\":\"Active\"", html) || occursin("\"label\": \"Active\"", html)
@test occursin("\"label\":\"Inactive\"", html) || occursin("\"label\": \"Inactive\"", html)
@test occursin("\"label\":\"Pending\"", html) || occursin("\"label\": \"Pending\"", html)

# Verify filter function is set (default is now multiselect, so "in")
@test occursin("\"headerFilterFunc\": \"in\"", html) || occursin("\"headerFilterFunc\":\"in\"", html)

# Verify multiselect is present (since default is multiselect=true)
@test occursin("\"multiselect\"", html)

# Verify placeholder is set
@test occursin("\"headerFilterPlaceholder\": \"Select...\"", html)
