
using CSV
using DataFrames
using TableExplorer
using TableExplorer: explore_table_debug

df_pivot = CSV.File(joinpath(@__DIR__,"sample.csv")) |> DataFrame

##

explore_table(
    df_pivot, 
    [n=>ColumnHeatmap(; min_value=8.0, max_value=30.0) for n in names(df_pivot) if n != "pivot_row"]...
)
##
