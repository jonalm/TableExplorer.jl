using Test
using TableExplorer

# Verify that public API is exported
@test isdefined(TableExplorer, :explore_table)
@test isdefined(TableExplorer, :ColumnText)
@test isdefined(TableExplorer, :ColumnNumeric)
@test isdefined(TableExplorer, :ColumnCategorical)
@test isdefined(TableExplorer, :ColumnDateTime)

# Verify they're actually exported (accessible without TableExplorer. prefix)
using TableExplorer
@test isdefined(Main, :explore_table)
@test isdefined(Main, :ColumnText)
@test isdefined(Main, :ColumnNumeric)
@test isdefined(Main, :ColumnCategorical)
@test isdefined(Main, :ColumnDateTime)
