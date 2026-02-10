using Test
using TableExplorer

# Test defaults
col = ColumnCategorical()
@test col.color_map === nothing
@test col.search_type == :dropdown
@test col.show_colors == true
@test col.palette == TableExplorer.DEFAULT_CATEGORICAL_PALETTE
@test col.multiselect == true  # Default changed to true

# Test with custom color map
custom_colors = Dict("A" => "#ff0000", "B" => "#00ff00")
col_custom = ColumnCategorical(color_map=custom_colors)
@test col_custom.color_map == custom_colors

# Test with custom palette
custom_palette = ["#111111", "#222222"]
col_palette = ColumnCategorical(palette=custom_palette)
@test col_palette.palette == custom_palette

# Test with show_colors=false
col_no_colors = ColumnCategorical(show_colors=false)
@test col_no_colors.show_colors == false

# Test with multiselect=true
col_multiselect = ColumnCategorical(multiselect=true)
@test col_multiselect.multiselect == true
