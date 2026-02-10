using Test
using TableExplorer
using DataFrames
using Dates

df = DataFrame(date = [Date(2024, 1, 1)])
col = ColumnDateTime()
result = TableExplorer.create_formatter(col, df, :date)
@test result === nothing  # Currently no special formatting
