module TableExplorer

using JSON
using Tables
using ColorSchemes
using Colors: hex

export explore_table,
    # columns
    BooleanColumn,
    CategoricalColumn,
    DateTimeColumn,
    NumericalHeatMap,
    NumericColumn,
    TextColumn


include("utils.jl")
include("columntypes.jl")
include("table_html.jl")
include("api.jl")


end