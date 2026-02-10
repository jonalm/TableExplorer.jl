using Test
using TableExplorer
using DataFrames

df = DataFrame(value = [1.5, 2.5, 3.5])

# ColumnHeatmap has no filter
col = ColumnHeatmap()
result = TableExplorer.create_header_filter_config(col, df, :value)
@test result isa TableExplorer.HeaderFilterConfig
@test result.filter_type == ""
@test result.filter_func == ""
@test result.placeholder == ""
@test result.values === nothing
