using Test
using TableExplorer
using DataFrames

df = DataFrame(
    status = ["Active", "Inactive", "Pending"],
    value = [1, 2, 3]
)

# Test with multiselect enabled
html = TableExplorer.table_html(df,
    :status => ColumnCategorical(multiselect=true)
)

@test html isa String

# Verify multiselect is in headerFilterParams
@test occursin("\"multiselect\": true", html) || occursin("\"multiselect\":true", html)

# Verify filter function is "in" for multiselect
@test occursin("\"headerFilterFunc\": \"in\"", html) || occursin("\"headerFilterFunc\":\"in\"", html)

# Test without multiselect (explicit single select)
html_single = TableExplorer.table_html(df,
    :status => ColumnCategorical(multiselect=false)
)

@test html_single isa String

# Verify multiselect is NOT in headerFilterParams for single select
@test !occursin("\"multiselect\"", html_single)

# Verify filter function is "=" for single select
@test occursin("\"headerFilterFunc\": \"=\"", html_single) || occursin("\"headerFilterFunc\":\"=\"", html_single)
