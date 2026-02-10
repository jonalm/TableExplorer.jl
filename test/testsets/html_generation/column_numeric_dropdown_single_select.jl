using Test
using TableExplorer
using DataFrames

df = DataFrame(
    value = [1.5, NaN, 2.5]
)

# Generate HTML with single select numeric dropdown
html = TableExplorer.table_html(df,
    :value => ColumnNumeric(search_type=:dropdown, multiselect=false)
)

@test html isa String

# Verify multiselect is NOT enabled
@test !occursin("\"multiselect\"", html)

# Verify single select filter function is used
@test occursin("numericTypeSingleFilter", html)
