


"""
Abstract base type for all column types in TableExplorer.
Each concrete type defines how a column should be displayed and filtered.
All subtypes should be prefixed with `Column` e.g. see `ColumnText` below
"""
abstract type ColumnType end

"""
    ColumnText(; search_type=:regex)

Column type for text data.

# Fields
- `search_type::Symbol`: Type of header filter (`:regex`, `:exact`, `:contains`)

# Examples
```julia
explore_table(df, "name" => ColumnText(search_type=:regex))
```
"""
Base.@kwdef struct ColumnText <: ColumnType
    search_type::Symbol = :regex
end

"""
    ColumnNumeric(; decimal_places=nothing, alignment=:right, search_type=:input)

Column type for numeric data.

# Fields
- `decimal_places::Union{Int, Nothing}`: Number of decimal places to display (nothing = auto)
- `alignment::Symbol`: Text alignment (`:left`, `:right`, `:center`)
- `search_type::Symbol`: Type of header filter (`:input`, `:range`)

# Examples
```julia
explore_table(df,
    "price" => ColumnNumeric(decimal_places=2, alignment=:right),
    "count" => ColumnNumeric(decimal_places=0)
)
```
"""
Base.@kwdef struct ColumnNumeric <: ColumnType
    decimal_places::Union{Int, Nothing} = nothing
    alignment::Symbol = :right
    search_type::Symbol = :input
end

"""
    ColumnCategorical(; color_map=nothing, search_type=:input, show_colors=true, palette=DEFAULT_CATEGORICAL_PALETTE)

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
    "status" => ColumnCategorical(
        color_map=Dict("Active" => "#28a745", "Inactive" => "#dc3545")
    )
)

# Auto-generated colors
explore_table(df, "category" => ColumnCategorical())
```
"""
Base.@kwdef struct ColumnCategorical <: ColumnType
    color_map::Union{Dict{String, String}, Nothing} = nothing
    search_type::Symbol = :input
    show_colors::Bool = true
    palette::Vector{String} = DEFAULT_CATEGORICAL_PALETTE
end

"""
    ColumnDateTime(; format="yyyy-mm-dd HH:MM:SS", search_type=:input)

Column type for date/time data.

# Fields
- `format::String`: Display format string
- `search_type::Symbol`: Type of header filter (`:input`, `:range`)

# Examples
```julia
explore_table(df,
    "timestamp" => ColumnDateTime(format="yyyy-mm-dd"),
    "created_at" => ColumnDateTime(search_type=:range)
)
```
"""
Base.@kwdef struct ColumnDateTime <: ColumnType
    format::String = "yyyy-mm-dd HH:MM:SS"
    search_type::Symbol = :input
end

"""
    ColumnBoolean(; search_type=:dropdown, true_label="✓", false_label="✗")

Column type for boolean data.

# Fields
- `search_type::Symbol`: Type of header filter (`:dropdown`, `:exact`, `:input`)
- `true_label::String`: Display label for true values
- `false_label::String`: Display label for false values

# Examples
```julia
explore_table(df,
    "is_active" => ColumnBoolean(true_label="Yes", false_label="No")
)
```
"""
Base.@kwdef struct ColumnBoolean <: ColumnType
    search_type::Symbol = :dropdown
    true_label::String = "✓"
    false_label::String = "✗"
end


"""
    HeaderFilterConfig

Configuration for column header filters in Tabulator.

# Fields
- `filter_type::String`: Type of filter widget (e.g., "input", "select")
- `filter_func::String`: Tabulator filter function name (e.g., "regex", "=", "like", ">=")
- `placeholder::String`: Placeholder text for filter input
"""
struct HeaderFilterConfig
    filter_type::String
    filter_func::String
    placeholder::String
end


"""
    create_header_filter_config(col_type::ColumnType)::HeaderFilterConfig

Create header filter configuration for a column type.
Returns a HeaderFilterConfig with filter_type, filter_func, and placeholder.
"""
function create_header_filter_config(col_type::ColumnText)::HeaderFilterConfig
    if col_type.search_type == :regex
        return HeaderFilterConfig("input", "regex", "Regex search...")
    elseif col_type.search_type == :exact
        return HeaderFilterConfig("input", "=", "Exact match...")
    elseif col_type.search_type == :contains
        return HeaderFilterConfig("input", "like", "Contains...")
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnNumeric)::HeaderFilterConfig
    if col_type.search_type == :range
        return HeaderFilterConfig("input", ">=", "Min value...")  # TODO: Implement proper range filter
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnCategorical)::HeaderFilterConfig
    if col_type.search_type == :dropdown
        return HeaderFilterConfig("input", "=", "Select...")  # TODO: Implement dropdown
    elseif col_type.search_type == :exact
        return HeaderFilterConfig("input", "=", "Exact match...")
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnDateTime)::HeaderFilterConfig
    if col_type.search_type == :range
        return HeaderFilterConfig("input", ">=", "Date...")  # TODO: Implement date range
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnBoolean)::HeaderFilterConfig
    if col_type.search_type == :dropdown
        return HeaderFilterConfig("input", "=", "True/False...")  # TODO: Implement dropdown
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end


"""
    create_formatter(col_type::ColumnType, df::DataFrame, colname::String)

Create JavaScript formatter function for a column type.
Returns nothing if no special formatting needed.
"""
function create_formatter(col_type::ColumnText, table, colname)
    return nothing  # No special formatting for text
end

function create_formatter(col_type::ColumnNumeric, table, colname)
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

function create_formatter(col_type::ColumnCategorical, table, colname)
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

function create_formatter(col_type::ColumnDateTime, table, colname)
    # For now, return nothing - could add date formatting later
    return nothing
end

function create_formatter(col_type::ColumnBoolean, table, colname)
    true_label = js_string_literal(col_type.true_label)
    false_label = js_string_literal(col_type.false_label)
    return """function(cell) {
      var val = cell.getValue();
      if (val == null || val === '') return '';
      return val ? '$true_label' : '$false_label';
    }"""
end


"""
    get_alignment(col_type::ColumnType)

Get text alignment for a column type.
"""
get_alignment(col_type::ColumnText) = nothing
get_alignment(col_type::ColumnNumeric) = string(col_type.alignment)
get_alignment(col_type::ColumnCategorical) = nothing
get_alignment(col_type::ColumnDateTime) = nothing
get_alignment(col_type::ColumnBoolean) = "center"

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

    # Add header filter configuration
    filter_config = create_header_filter_config(col_type)
    config["headerFilter"] = filter_config.filter_type
    config["headerFilterFunc"] = filter_config.filter_func
    config["headerFilterPlaceholder"] = filter_config.placeholder

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
        return ColumnText()
    end

    # Check for boolean columns (before Number check since Bool <: Number)
    if non_missing_type <: Bool
        return ColumnBoolean()
    end

    # Check for numeric columns
    if non_missing_type <: Number
        return ColumnNumeric()
    end

    # Check for categorical string columns
    if non_missing_type <: Union{AbstractString, String} && !isnothing(auto_categorical_threshold)
        # Use early-exit iteration to avoid processing entire column for large datasets
        seen = Set{String}()
        for val in col_data
            if !ismissing(val) && val !== nothing && val != ""
                push!(seen, string(val))
                # Short-circuit if we exceed threshold
                if length(seen) > auto_categorical_threshold
                    return ColumnText()
                end
            end
        end
        # Return categorical if we found valid values within threshold
        return length(seen) > 0 ? ColumnCategorical() : ColumnText()
    end

    # Default to text column
    return ColumnText()
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
