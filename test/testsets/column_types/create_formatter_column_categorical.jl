using Test
using TableExplorer
using DataFrames

df = DataFrame(status = ["Active", "Inactive", "Pending"])

# Test with manual color map
color_map = Dict("Active" => "#00ff00", "Inactive" => "#ff0000")
col = ColumnCategorical(color_map=color_map)
result = TableExplorer.create_formatter(col, df, :status)
@test result isa String
@test occursin("Active", result)
@test occursin("#00ff00", result)

# Test with auto-generated colors
col_auto = ColumnCategorical()
result_auto = TableExplorer.create_formatter(col_auto, df, :status)
@test result_auto isa String
@test occursin("backgroundColor", result_auto)

# Test with show_colors=false
col_no_colors = ColumnCategorical(show_colors=false)
result_no_colors = TableExplorer.create_formatter(col_no_colors, df, :status)
@test result_no_colors === nothing

# Test with empty column
df_empty = DataFrame(status = String[])
result_empty = TableExplorer.create_formatter(col_auto, df_empty, :status)
@test result_empty === nothing
