using Test
using TableExplorer
using DataFrames

df = DataFrame(
    value = [1.5, NaN, Inf, -Inf, missing, 2.5]
)

# Generate HTML with numeric dropdown
html = TableExplorer.table_html(df,
    :value => ColumnNumeric(search_type=:dropdown)
)

@test html isa String

# Verify list filter is used
@test occursin("\"headerFilter\": \"list\"", html) || occursin("\"headerFilter\":\"list\"", html)

# Verify all value types are present in dropdown
@test occursin("\"label\":\"numerical\"", html) || occursin("\"label\": \"numerical\"", html)
@test occursin("\"label\":\"NaN\"", html) || occursin("\"label\": \"NaN\"", html)
@test occursin("\"label\":\"Infinity\"", html) || occursin("\"label\": \"Infinity\"", html)
@test occursin("\"label\":\"-Infinity\"", html) || occursin("\"label\": \"-Infinity\"", html)
@test occursin("\"label\":\"(null)\"", html) || occursin("\"label\": \"(null)\"", html)

# Verify multiselect is enabled by default
@test occursin("\"multiselect\": true", html) || occursin("\"multiselect\":true", html)

# Verify custom filter function is used
@test occursin("numericTypeFilter", html)
