module TableExplorer

using JSON
using Tables
using ColorSchemes
using Colors: hex
using Dates

export explore_table,
    # columns
    ColumnBoolean,
    ColumnCategorical,
    ColumnDateTime,
    ColumnNumeric,
    ColumnText


include("utils.jl")
include("column_types.jl")
include("table_html.jl")
include("api.jl")


end