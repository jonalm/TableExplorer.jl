
"""
Helper function to check if a key-value pair represents a JavaScript function
"""
function is_js_function(key::String, value)
    value isa String &&
    (key == "formatter" || key == "titleFormatter" || endswith(key, "Formatter")) &&
    startswith(strip(value), "function")
end

"""
Helper function to serialize column config to JSON with special handling for functions
"""
function config_to_json(config)
    parts = map(collect(config)) do (k, v)
        if is_js_function(k, v)
            "\"$(k)\": $(v)"  # Don't quote function definitions
        else
            "\"$(k)\": $(JSON.json(v))"
        end
    end
    return "{" * join(parts, ", ") * "}"
end



"""
    table_html(table, column_types::Pair{<:Union{String,Symbol}, <:ColumnType}...; auto_categorical_threshold=10) -> String

Generates a standalone HTML page with an interactive table viewer for any Tables.jl-compatible table.

# Arguments
- `table`: Any table that implements the Tables.jl interface (DataFrame, NamedTuple of vectors, etc.)
- `column_types`: Variable number of column_name => ColumnType pairs. Column names can be String or Symbol.

# Keyword Arguments
- `auto_categorical_threshold::Union{Int, Nothing}`: Threshold for automatic categorical detection (default: 10).
  String columns with ≤ threshold unique values will automatically get colored cells.
  Set to `nothing` to disable automatic detection. Only applies to columns without explicit types.

# Returns
HTML string containing a fully functional interactive table

# Column Types
Specify custom formatting and search behavior for columns using Pair syntax:
- `ColumnText`: Text data with regex/exact/contains search
- `ColumnNumeric`: Numbers with decimal formatting and alignment
- `ColumnCategorical`: Categorical data with optional color coding
- `ColumnDateTime`: Date/time data with custom formatting
- `ColumnBoolean`: Boolean data with custom labels

# Features
- Uses [Tabulator.js](https://tabulator.info/) library for rich table interactions
- **Filtering**: Configurable search filters in column headers
- **Sorting**: Click headers to sort (nulls/missing values sorted to bottom)
- **Export**: CSV and JSON export buttons
- **Column control**: Show/hide columns via dropdown menu
- **Responsive**: Full-height viewport with movable/resizable columns
- **Tables.jl compatible**: Works with any table type (DataFrame, CSV, Arrow, etc.)

# Examples
```julia
# Automatic detection (all columns)
table_html(df)

# Specify column types using Pairs (String or Symbol keys)
table_html(df,
    :status => ColumnCategorical(
        color_map=Dict("Active" => "#28a745", "Inactive" => "#dc3545")
    ),
    :price => ColumnNumeric(decimal_places=2),
    :count => ColumnNumeric(decimal_places=0)
)

# Mix manual types with auto-detection
table_html(df,
    "status" => ColumnCategorical(color_map=my_colors),
    # other columns use auto-detection
    auto_categorical_threshold=15
)
```

# Implementation notes
- Uses Tables.jl interface for maximum compatibility
- Uses JSON.jl for data serialization
- Auto-detects column types for columns without explicit type specification
- Handles missing, NaN, and empty values gracefully
- Loads CSS and JS from separate template files
"""
function table_html(
    table,
    column_types::Pair{<:Union{String,Symbol}, <:ColumnType}...;
    auto_categorical_threshold::Union{Int, Nothing}=10
)
    # Ensure table implements Tables.jl interface
    if !Tables.istable(table)
        throw(ArgumentError("Input must implement Tables.jl interface"))
    end

    # Get table schema and column information
    schema = Tables.schema(table)
    colnames = schema === nothing ? collect(Tables.columnnames(Tables.columns(table))) : collect(schema.names)
    ncols = length(colnames)

    # Convert column_types to a Dict with Symbol keys for consistent lookup
    col_type_dict = Dict{Symbol, ColumnType}(Symbol(k) => v for (k, v) in column_types)

    # Convert table to array of dictionaries for JSON serialization
    data_rows = map(Base.Fix2(row_to_dict, colnames), Tables.rows(table))
    nrows = length(data_rows)

    data_json = JSON.json(data_rows)

    # Create column configurations
    column_configs = map(colnames) do colname
        col_type = get_or_detect_column_type(table, colname, col_type_dict, auto_categorical_threshold)
        create_column_config(table, colname, col_type)
    end

    columns_json = "[" * join(config_to_json.(column_configs), ", ") * "]"

    # Calculate dynamic header height for ColumnHeatmap columns
    heatmap_col_names = String[]
    for colname in colnames
        col_type = get_or_detect_column_type(table, colname, col_type_dict, auto_categorical_threshold)
        if col_type isa ColumnHeatmap
            push!(heatmap_col_names, String(colname))
        end
    end

    # Calculate header height based on longest column name (with buffer)
    # Assume ~8px per character width, add 40px buffer for padding and rotation
    max_header_height = if isempty(heatmap_col_names)
        60  # Default height if no heatmap columns
    else
        max_name_length = maximum(length, heatmap_col_names)
        min(200, max_name_length * 8 + 40)
    end

    # Custom CSS for dynamic header height and rotated headers
    custom_css = """
    .tabulator .tabulator-header {
        min-height: $(max_header_height)px !important;
    }
    .tabulator .tabulator-col {
        min-height: $(max_header_height)px !important;
    }
    .rotated-header {
        display: block;
        transform: rotate(-90deg);
        transform-origin: left bottom;
        white-space: nowrap;
        margin-top: $(max_header_height)px;
        margin-left: 15px;
    }
    """

    # Load static files
    static_files = ["tableexplorer_template.html", "tableexplorer.css", "tableexplorer.js"]
    template, css_content, js_content = [read(joinpath(@__DIR__, f), String) for f in static_files]

    # Replace all placeholders
    replacements = Dict(
        "{{CSS_CONTENT}}" => css_content * "\n" * custom_css,
        "{{JS_CONTENT}}" => js_content,
        "{{NROWS}}" => string(nrows),
        "{{NCOLS}}" => string(ncols),
        "{{TABLE_DATA}}" => data_json,
        "{{COLUMNS}}" => columns_json
    )

    return reduce((s, (k, v)) -> replace(s, k => v), replacements; init=template)
end

