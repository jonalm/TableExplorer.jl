


"""
    explore_table(table, column_types::Pair{<:Union{String,Symbol}, <:ColumnType}...; auto_categorical_threshold=10)

Opens an interactive HTML table view of any Tables.jl-compatible table in the system's default browser.

# Arguments
- `table`: Any table that implements the Tables.jl interface (DataFrame, NamedTuple of vectors, etc.)
- `column_types`: Variable number of column_name => ColumnType pairs. Column names can be String or Symbol.

# Keyword Arguments
- `auto_categorical_threshold::Union{Int, Nothing}`: Threshold for automatic categorical detection (default: 10)

See `table_html` documentation for detailed explanation of column types and features.

# Behavior
1. Generates HTML via `table_html(table, column_types...; auto_categorical_threshold)`
2. Writes to temporary file (`explore_table.html` in `mktempdir()`)
3. Opens file in default browser using platform-specific commands:
   - macOS: `open`
   - Windows: `cmd /c start`
   - Linux: `xdg-open`

# Examples
```julia
using DataFrames
df = DataFrame(
    status = ["Active", "Inactive", "Pending"],
    priority = ["High", "Low", "Medium"],
    value = [100, 200, 300],
    price = [10.5, 20.75, 15.25]
)

# Automatic detection (default)
explore_table(df)

# Specify column types using Pairs (String or Symbol keys)
explore_table(df,
    "status" => ColumnCategorical(
        color_map=Dict("Active" => "#28a745", "Inactive" => "#6c757d", "Pending" => "#ffc107")
    ),
    :priority => ColumnCategorical(
        color_map=Dict("High" => "#dc3545", "Medium" => "#fd7e14", "Low" => "#20c997")
    ),
    :price => ColumnNumeric(decimal_places=2)
)

# Mix manual and auto-detection
explore_table(df,
    :status => ColumnCategorical(color_map=my_colors),
    auto_categorical_threshold=
)
```
"""
function explore_table(
    table,
    column_types::Pair{<:Union{String,Symbol}, <:ColumnType}...;
    auto_categorical_threshold::Union{Int, Nothing}=nothing, outdir=nothing
)
    auto_categorical_threshold = isnothing(auto_categorical_threshold) ? length(DEFAULT_CATEGORICAL_PALETTE) : auto_categorical_threshold
    if isnothing(outdir) 
        dir = mktempdir()
    else
        mkpath(dir)
        dir = outdir
    end
    html_path = joinpath(dir, "explore_table.html")
    write(html_path, table_html(table, column_types...; auto_categorical_threshold=auto_categorical_threshold))
    open_in_browser(html_path)
end

