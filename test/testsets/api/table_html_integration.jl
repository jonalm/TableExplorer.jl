using Test
using TableExplorer
using TableExplorer: table_html
using DataFrames

# Verify table_html is not exported but is accessible
@test isdefined(TableExplorer, :table_html)
@test applicable(table_html, DataFrame(a=[1]))
