using Test
using TableExplorer

# Test defaults
col = ColumnHeatmap()
@test col.min_value === nothing
@test col.max_value === nothing
@test col.alignment == :center
@test col.palette == TableExplorer.CONTINUOUS_PALETTE

# Test with explicit min/max
col_custom = ColumnHeatmap(min_value=0.0, max_value=100.0)
@test col_custom.min_value == 0.0
@test col_custom.max_value == 100.0

# Test with custom alignment
col_align = ColumnHeatmap(alignment=:right)
@test col_align.alignment == :right

# Test with custom palette
custom_palette = ["#000000", "#ffffff"]
col_palette = ColumnHeatmap(palette=custom_palette)
@test col_palette.palette == custom_palette
