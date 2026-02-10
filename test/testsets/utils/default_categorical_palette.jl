using Test
using TableExplorer

@test all(color -> startswith(color, "#"), TableExplorer.DEFAULT_CATEGORICAL_PALETTE)
@test all(color -> length(color) == 7, TableExplorer.DEFAULT_CATEGORICAL_PALETTE)
