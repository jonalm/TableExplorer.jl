using Test
using TableExplorer

# Test defaults
col = ColumnNumeric()
@test col.decimal_places === nothing
@test col.alignment == :right
@test col.search_type == :input

# Test with custom values
col_custom = ColumnNumeric(decimal_places=3, alignment=:left)
@test col_custom.decimal_places == 3
@test col_custom.alignment == :left
