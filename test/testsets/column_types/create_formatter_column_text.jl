using Test
using TableExplorer
using DataFrames

df = DataFrame(name = ["Alice", "Bob"])
col = ColumnText()
result = TableExplorer.create_formatter(col, df, :name)
@test result === nothing
