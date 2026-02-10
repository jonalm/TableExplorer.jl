using Test
using TableExplorer

@test TableExplorer.get_alignment(ColumnHeatmap()) === nothing
@test TableExplorer.get_alignment(ColumnHeatmap(alignment=:left)) === nothing
@test TableExplorer.get_alignment(ColumnHeatmap(alignment=:right)) === nothing
