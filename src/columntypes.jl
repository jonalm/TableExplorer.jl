


"""
Abstract base type for all column types in TableView.
Each concrete type defines how a column should be displayed and filtered.
"""
abstract type ColumnType end

"""
    TextColumn(; search_type=:regex)

Column type for text data.

# Fields
- `search_type::Symbol`: Type of header filter (`:regex`, `:exact`, `:contains`)

# Examples
```julia
explore_table(df, "name" => TextColumn(search_type=:regex))
```
"""
Base.@kwdef struct TextColumn <: ColumnType
    search_type::Symbol = :regex
end

"""
    NumericColumn(; decimal_places=nothing, alignment=:right, search_type=:input)

Column type for numeric data.

# Fields
- `decimal_places::Union{Int, Nothing}`: Number of decimal places to display (nothing = auto)
- `alignment::Symbol`: Text alignment (`:left`, `:right`, `:center`)
- `search_type::Symbol`: Type of header filter (`:input`, `:range`)

# Examples
```julia
explore_table(df,
    "price" => NumericColumn(decimal_places=2, alignment=:right),
    "count" => NumericColumn(decimal_places=0)
)
```
"""
Base.@kwdef struct NumericColumn <: ColumnType
    decimal_places::Union{Int, Nothing} = nothing
    alignment::Symbol = :right
    search_type::Symbol = :input
end

"""
    CategoricalColumn(; color_map=nothing, search_type=:input, show_colors=true, palette=DEFAULT_CATEGORICAL_PALETTE)

Column type for categorical data with optional color coding.

# Fields
- `color_map::Union{Dict{String,String}, Nothing}`: Manual color mapping (value => hex color)
- `search_type::Symbol`: Type of header filter (`:input`, `:dropdown`, `:exact`)
- `show_colors::Bool`: Whether to apply cell background colors
- `palette::Vector{String}`: Color palette for auto-generation if color_map not provided

# Examples
```julia
# Manual colors
explore_table(df,
    "status" => CategoricalColumn(
        color_map=Dict("Active" => "#28a745", "Inactive" => "#dc3545")
    )
)

# Auto-generated colors
explore_table(df, "category" => CategoricalColumn())
```
"""
Base.@kwdef struct CategoricalColumn <: ColumnType
    color_map::Union{Dict{String, String}, Nothing} = nothing
    search_type::Symbol = :input
    show_colors::Bool = true
    palette::Vector{String} = DEFAULT_CATEGORICAL_PALETTE
end

"""
    DateTimeColumn(; format="yyyy-mm-dd HH:MM:SS", search_type=:input)

Column type for date/time data.

# Fields
- `format::String`: Display format string
- `search_type::Symbol`: Type of header filter (`:input`, `:range`)

# Examples
```julia
explore_table(df,
    "timestamp" => DateTimeColumn(format="yyyy-mm-dd"),
    "created_at" => DateTimeColumn(search_type=:range)
)
```
"""
Base.@kwdef struct DateTimeColumn <: ColumnType
    format::String = "yyyy-mm-dd HH:MM:SS"
    search_type::Symbol = :input
end

"""
    BooleanColumn(; search_type=:dropdown, true_label="✓", false_label="✗")

Column type for boolean data.

# Fields
- `search_type::Symbol`: Type of header filter (`:dropdown`, `:exact`, `:input`)
- `true_label::String`: Display label for true values
- `false_label::String`: Display label for false values

# Examples
```julia
explore_table(df,
    "is_active" => BooleanColumn(true_label="Yes", false_label="No")
)
```
"""
Base.@kwdef struct BooleanColumn <: ColumnType
    search_type::Symbol = :dropdown
    true_label::String = "✓"
    false_label::String = "✗"
end

"""
    NumericalHeatMap(; min_value=nothing, max_value=nothing, palette=ColorSchemes.viridis)

Column type for numerical data displayed as a heatmap with colored quadratic cells.

# Fields
- `min_value::Union{Float64, Nothing}`: Minimum value for color scale (nothing = auto from data)
- `max_value::Union{Float64, Nothing}`: Maximum value for color scale (nothing = auto from data)
- `palette::ColorScheme`: Color scheme to use (default: viridis)

# Features
- Cells are colored according to the viridis color scheme
- Cells are quadratic (equal width and height)
- No text displayed in cells
- No filtering available
- Column header is rotated 90 degrees

# Examples
```julia
explore_table(df,
    "score" => NumericalHeatMap()
)

# Custom min/max values
explore_table(df,
    "intensity" => NumericalHeatMap(min_value=0.0, max_value=100.0)
)

# Different color scheme
explore_table(df,
    "correlation" => NumericalHeatMap(palette=ColorSchemes.RdBu)
)
```
"""
Base.@kwdef struct NumericalHeatMap <: ColumnType
    min_value::Union{Float64, Nothing} = nothing
    max_value::Union{Float64, Nothing} = nothing
    palette::ColorSchemes.ColorScheme = ColorSchemes.viridis
end




"""
    create_header_filter_config(col_type::ColumnType)

Create header filter configuration for a column type.
Returns a tuple of (filter_type, filter_func, placeholder).
"""
function create_header_filter_config(col_type::TextColumn)
    if col_type.search_type == :regex
        return ("input", "regex", "Regex search...")
    elseif col_type.search_type == :exact
        return ("input", "=", "Exact match...")
    elseif col_type.search_type == :contains
        return ("input", "like", "Contains...")
    else
        return ("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::NumericColumn)
    if col_type.search_type == :range
        return ("input", ">=", "Min value...")  # TODO: Implement proper range filter
    else
        return ("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::CategoricalColumn)
    if col_type.search_type == :dropdown
        return ("input", "=", "Select...")  # TODO: Implement dropdown
    elseif col_type.search_type == :exact
        return ("input", "=", "Exact match...")
    else
        return ("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::DateTimeColumn)
    if col_type.search_type == :range
        return ("input", ">=", "Date...")  # TODO: Implement date range
    else
        return ("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::BooleanColumn)
    if col_type.search_type == :dropdown
        return ("input", "=", "True/False...")  # TODO: Implement dropdown
    else
        return ("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::NumericalHeatMap)
    # No filtering for heatmap columns
    return (nothing, nothing, nothing)
end

"""
    create_formatter(col_type::ColumnType, df::DataFrame, colname::String)

Create JavaScript formatter function for a column type.
Returns nothing if no special formatting needed.
"""
function create_formatter(col_type::TextColumn, table, colname)
    return nothing  # No special formatting for text
end

function create_formatter(col_type::NumericColumn, table, colname)
    if !isnothing(col_type.decimal_places)
        dp = col_type.decimal_places
        return "function(cell) { var val = cell.getValue(); return val == null ? '' : val.toFixed($dp); }"
    else
        # Get column data to determine element type
        cols = Tables.columns(table)
        col_data = Tables.getcolumn(cols, colname)
        eltype_col = eltype(col_data)

        if eltype_col <: AbstractFloat
            return "function(cell) { var val = cell.getValue(); return val == null ? '' : val.toFixed(2); }"
        else
            return "function(cell) { var val = cell.getValue(); return val == null ? '' : val.toLocaleString(); }"
        end
    end
end

function create_formatter(col_type::CategoricalColumn, table, colname)
    if !col_type.show_colors
        return nothing
    end

    # Use provided color_map or generate from data
    if !isnothing(col_type.color_map)
        color_map = col_type.color_map
    else
        # Generate colors from unique values in the data
        cols = Tables.columns(table)
        col_data = Tables.getcolumn(cols, colname)
        unique_vals = unique(skipmissing(col_data))
        if isempty(unique_vals)
            return nothing
        end
        color_map = generate_categorical_colors(collect(unique_vals), col_type.palette)
    end

    return create_categorical_formatter(color_map)
end

function create_formatter(col_type::DateTimeColumn, table, colname)
    # For now, return nothing - could add date formatting later
    return nothing
end

function create_formatter(col_type::BooleanColumn, table, colname)
    true_label = col_type.true_label
    false_label = col_type.false_label
    return """function(cell) {
      var val = cell.getValue();
      if (val == null || val === '') return '';
      return val ? '$true_label' : '$false_label';
    }"""
end

function create_formatter(col_type::NumericalHeatMap, table, colname)
    # Get column data to determine min/max values
    cols = Tables.columns(table)
    col_data = Tables.getcolumn(cols, colname)

    # Filter out missing, NaN, Inf values
    valid_values = filter(x -> !ismissing(x) && !isnan(x) && !isinf(x), col_data)

    if isempty(valid_values)
        # No valid data, return empty formatter
        return """function(cell) { return ''; }"""
    end

    # Determine min and max values
    min_val = !isnothing(col_type.min_value) ? col_type.min_value : minimum(valid_values)
    max_val = !isnothing(col_type.max_value) ? col_type.max_value : maximum(valid_values)

    # Sample colors from the viridis palette
    # Generate 256 color steps for smooth gradients
    n_colors = 256
    indices = range(0, 1, length=n_colors)
    color_palette = [string("#", hex(get(col_type.palette, idx))) for idx in indices]

    # Create JavaScript array of colors
    colors_js = "[" * join(("'$c'" for c in color_palette), ", ") * "]"

    # Create formatter that applies heatmap coloring
    formatter = """function(cell) {
      var val = cell.getValue();
      if (val == null || val === '' || isNaN(val) || !isFinite(val)) {
        var cellElement = cell.getElement();
        cellElement.style.backgroundColor = '#ffffff';
        return '';
      }

      var minVal = $min_val;
      var maxVal = $max_val;
      var colors = $colors_js;

      // Normalize value to [0, 1]
      var normalized = (val - minVal) / (maxVal - minVal);
      normalized = Math.max(0, Math.min(1, normalized)); // Clamp to [0, 1]

      // Map to color index
      var colorIdx = Math.floor(normalized * (colors.length - 1));
      var color = colors[colorIdx];

      // Apply color to cell
      var cellElement = cell.getElement();
      cellElement.style.backgroundColor = color;
      cellElement.classList.add('heatmap-cell');

      // Return empty string (no text displayed)
      return '';
    }"""

    return formatter
end

"""
    get_alignment(col_type::ColumnType)

Get text alignment for a column type.
"""
get_alignment(col_type::TextColumn) = nothing
get_alignment(col_type::NumericColumn) = string(col_type.alignment)
get_alignment(col_type::CategoricalColumn) = nothing
get_alignment(col_type::DateTimeColumn) = nothing
get_alignment(col_type::BooleanColumn) = "center"
get_alignment(col_type::NumericalHeatMap) = "center"

"""
    create_column_config(table, colname, col_type::ColumnType)

Create complete column configuration for a specific column type.
"""
function create_column_config(table, colname, col_type::ColumnType)
    colname_str = String(colname)

    config = Dict{String, Any}(
        "title" => colname_str,
        "field" => colname_str,
        "headerSort" => true
    )

    # Add header filter configuration (if filtering is enabled for this column type)
    filter_type, filter_func, placeholder = create_header_filter_config(col_type)
    if !isnothing(filter_type)
        config["headerFilter"] = filter_type
        config["headerFilterFunc"] = filter_func
        config["headerFilterPlaceholder"] = placeholder
    end

    # Add formatter if needed
    formatter = create_formatter(col_type, table, colname)
    if !isnothing(formatter)
        config["formatter"] = formatter
    end

    # Add alignment if specified
    alignment = get_alignment(col_type)
    if !isnothing(alignment)
        config["align"] = alignment
    end

    # Special handling for NumericalHeatMap columns
    if col_type isa NumericalHeatMap
        # Set fixed width for quadratic cells
        config["width"] = 40
        config["minWidth"] = 40
        config["maxWidth"] = 40
        # Add CSS class to identify heatmap columns for styling
        config["headerHozAlign"] = "center"
    end

    return config
end

"""
    auto_detect_column_type(table, colname; auto_categorical_threshold=10)

Automatically detect the best column type for a column based on its data type and values.
Handles missing, NaN, and empty values robustly.
"""
function auto_detect_column_type(table, colname; auto_categorical_threshold=10)
    # Get the column data
    cols = Tables.columns(table)
    col_data = Tables.getcolumn(cols, colname)

    # Determine element type
    eltype_col = eltype(col_data)

    # Get non-missing type
    non_missing_type = eltype_col >: Missing ? Base.nonmissingtype(eltype_col) : eltype_col

    # Handle Nothing type
    if non_missing_type == Nothing
        return TextColumn()
    end

    # Check for boolean columns (before Number check since Bool <: Number)
    if non_missing_type <: Bool
        return BooleanColumn()
    end

    # Check for numeric columns
    if non_missing_type <: Number
        return NumericColumn()
    end

    # Check for categorical string columns
    if non_missing_type <: Union{AbstractString, String} && !isnothing(auto_categorical_threshold)
        # Filter out missing and collect unique values
        is_valid_value(val) = !ismissing(val) && val !== nothing && val != ""
        unique_vals = Set{String}(string(val) for val in col_data if is_valid_value(val))

        if length(unique_vals) <= auto_categorical_threshold && length(unique_vals) > 0
            return CategoricalColumn()  # Will auto-generate colors
        else
            return TextColumn()
        end
    end

    # Default to text column
    return TextColumn()
end


"""
    get_or_detect_column_type(table, colname, col_type_dict, auto_categorical_threshold)

Get the column type for a column, either from the explicit type dict or by auto-detection.

# Arguments
- `table`: The table containing the column
- `colname`: Name of the column (Symbol or String)
- `col_type_dict`: Dictionary mapping column names (as Symbols) to explicit ColumnType instances
- `auto_categorical_threshold`: Threshold for categorical auto-detection

# Returns
ColumnType instance for the column
"""
function get_or_detect_column_type(table, colname, col_type_dict, auto_categorical_threshold)
    colname_sym = Symbol(colname)

    if haskey(col_type_dict, colname_sym)
        # Use explicitly specified column type
        return col_type_dict[colname_sym]
    else
        # Auto-detect column type
        return auto_detect_column_type(table, colname; auto_categorical_threshold=auto_categorical_threshold)
    end
end
