


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
    search_type::Symbol = :input  # :input, :range, or :dropdown
    multiselect::Bool = true  # Only applies when search_type == :dropdown
end

"""
    ColumnCategorical(; color_map=nothing, search_type=:dropdown, show_colors=true, palette=DEFAULT_CATEGORICAL_PALETTE, multiselect=false)

Column type for categorical data with optional color coding.

# Fields
- `color_map::Union{Dict{String,String}, Nothing}`: Manual color mapping (value => hex color)
- `search_type::Symbol`: Type of header filter (`:dropdown`, `:input`, `:exact`)
- `show_colors::Bool`: Whether to apply cell background colors
- `palette::Vector{String}`: Color palette for auto-generation if color_map not provided
- `multiselect::Bool`: Whether to allow multiple selections in dropdown filter (default: false)

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

# With multiselect enabled
explore_table(df, "status" => ColumnCategorical(multiselect=true))
```
"""
Base.@kwdef struct ColumnCategorical <: ColumnType
    color_map::Union{Dict{String, String}, Nothing} = nothing
    search_type::Symbol = :dropdown
    show_colors::Bool = true
    palette::Vector{String} = DEFAULT_CATEGORICAL_PALETTE
    multiselect::Bool = true
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
    ColumnBoolean(; search_type=:dropdown, true_label="✓", false_label="✗", multiselect=false)

Column type for boolean data.

# Fields
- `search_type::Symbol`: Type of header filter (`:dropdown`, `:exact`, `:input`)
- `true_label::String`: Display label for true values
- `false_label::String`: Display label for false values
- `multiselect::Bool`: Whether to allow multiple selections in dropdown filter (default: false)

# Examples
```julia
explore_table(df,
    "is_active" => ColumnBoolean(true_label="Yes", false_label="No")
)

# With multiselect enabled (allows selecting both true and false)
explore_table(df, "flag" => ColumnBoolean(multiselect=true))
```
"""
Base.@kwdef struct ColumnBoolean <: ColumnType
    search_type::Symbol = :dropdown
    true_label::String = "✓"
    false_label::String = "✗"
    multiselect::Bool = false
end

"""
    ColumnHeatmap(; min_value=nothing, max_value=nothing, alignment=:center, palette=CONTINUOUS_PALETTE)

Column type for numeric data with heatmap visualization.
Values are displayed as colored cells (no text) using the viridis colorscheme.
Cells are rendered as squares with rotated column headers. No filtering is available.

Special value colors:
- Valid numbers: Viridis gradient based on value
- NaN/Inf/-Inf: Gray (#d3d3d3)
- missing/nothing: White (#ffffff)

# Fields
- `min_value::Union{Float64, Nothing}`: Minimum value for color scale (auto-computed if nothing)
- `max_value::Union{Float64, Nothing}`: Maximum value for color scale (auto-computed if nothing)
- `alignment::Symbol`: Text alignment (`:left`, `:right`, `:center`) - usually not visible
- `palette::Vector{String}`: Color palette (default: viridis with 256 colors)

# Examples
```julia
# Auto-detect min/max from data
explore_table(df, "temperature" => ColumnHeatmap())

# Explicit range (0-100)
explore_table(df, "score" => ColumnHeatmap(min_value=0.0, max_value=100.0))

# Custom palette
explore_table(df, "value" => ColumnHeatmap(palette=custom_colors))
```
"""
Base.@kwdef struct ColumnHeatmap <: ColumnType
    min_value::Union{Float64, Nothing} = nothing
    max_value::Union{Float64, Nothing} = nothing
    alignment::Symbol = :center
    palette::Vector{String} = CONTINUOUS_PALETTE
end


"""
    HeaderFilterConfig

Configuration for column header filters in Tabulator.

# Fields
- `filter_type::String`: Type of filter widget (e.g., "input", "list")
- `filter_func::String`: Tabulator filter function name (e.g., "regex", "=", "like", ">=")
- `placeholder::String`: Placeholder text for filter input
- `values::Union{Vector, Nothing}`: Optional list of values for dropdown filters
- `multiselect::Bool`: Whether to allow multiple selections in dropdown (default: false)
"""
struct HeaderFilterConfig
    filter_type::String
    filter_func::String
    placeholder::String
    values::Union{Vector, Nothing}
    multiselect::Bool
end

# Convenience constructor for configs without values
HeaderFilterConfig(filter_type::String, filter_func::String, placeholder::String) =
    HeaderFilterConfig(filter_type, filter_func, placeholder, nothing, false)

# Convenience constructor for configs with values but no multiselect
HeaderFilterConfig(filter_type::String, filter_func::String, placeholder::String, values) =
    HeaderFilterConfig(filter_type, filter_func, placeholder, values, false)


"""
    create_header_filter_config(col_type::ColumnType, table, colname)::HeaderFilterConfig

Create header filter configuration for a column type.
Returns a HeaderFilterConfig with filter_type, filter_func, placeholder, and optional values for dropdowns.
"""
function create_header_filter_config(col_type::ColumnText, _table, _colname)::HeaderFilterConfig
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

function create_header_filter_config(col_type::ColumnNumeric, table, colname)::HeaderFilterConfig
    if col_type.search_type == :dropdown
        # Detect which value types exist in the column
        cols = Tables.columns(table)
        col_data = Tables.getcolumn(cols, colname)

        has_numerical = false
        has_nan = false
        has_inf = false
        has_neg_inf = false
        has_null = false

        for val in col_data
            if ismissing(val) || val === nothing
                has_null = true
            elseif val isa AbstractFloat
                if isnan(val)
                    has_nan = true
                elseif isinf(val)
                    if val > 0
                        has_inf = true
                    else
                        has_neg_inf = true
                    end
                else
                    has_numerical = true
                end
            elseif val isa Number
                has_numerical = true
            end
        end

        # Build dropdown options based on what exists in the data
        values = Vector{Dict{String, Any}}()

        if has_numerical
            push!(values, Dict("label" => "numerical", "value" => "numerical"))
        end
        if has_nan
            push!(values, Dict("label" => "NaN", "value" => "NaN"))
        end
        if has_inf
            push!(values, Dict("label" => "Infinity", "value" => "Infinity"))
        end
        if has_neg_inf
            push!(values, Dict("label" => "-Infinity", "value" => "-Infinity"))
        end
        if has_null
            push!(values, Dict("label" => "(null)", "value" => "(null)"))
        end

        # Use custom filter function
        filter_func = col_type.multiselect ? "numericTypeFilter" : "numericTypeSingleFilter"
        return HeaderFilterConfig("list", filter_func, "Select...", values, col_type.multiselect)
    elseif col_type.search_type == :range
        return HeaderFilterConfig("input", ">=", "Min value...")  # TODO: Implement proper range filter
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnCategorical, table, colname)::HeaderFilterConfig
    if col_type.search_type == :dropdown
        # Extract unique values from the column, including Missing/Nothing
        cols = Tables.columns(table)
        col_data = Tables.getcolumn(cols, colname)

        # Collect unique values, preserving missing and nothing
        unique_vals = unique(col_data)

        # Track if we've seen a null value (missing or nothing)
        has_null = false

        # Convert to strings for display, handling special values
        # Filter out duplicates where both missing and nothing exist (they're both null)
        values = Vector{Dict{String, Any}}()
        for val in unique_vals
            if ismissing(val) || val === nothing
                # Both missing and nothing serialize to null, so only add one entry
                if !has_null
                    push!(values, Dict("label" => "(null)", "value" => nothing))
                    has_null = true
                end
            else
                str_val = string(val)
                push!(values, Dict("label" => str_val, "value" => str_val))
            end
        end

        # Sort by label for consistent display
        sort!(values, by = v -> v["label"])

        # Use "in" filter function for multiselect, "=" for single select
        filter_func = col_type.multiselect ? "in" : "="

        return HeaderFilterConfig("list", filter_func, "Select...", values, col_type.multiselect)
    elseif col_type.search_type == :exact
        return HeaderFilterConfig("input", "=", "Exact match...")
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnDateTime, _table, _colname)::HeaderFilterConfig
    if col_type.search_type == :range
        return HeaderFilterConfig("input", ">=", "Date...")  # TODO: Implement date range
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnBoolean, _table, _colname)::HeaderFilterConfig
    if col_type.search_type == :dropdown
        # Create dropdown with True/False options
        values = [
            Dict("label" => col_type.true_label, "value" => "true"),
            Dict("label" => col_type.false_label, "value" => "false")
        ]
        # Use "in" filter function for multiselect, "=" for single select
        filter_func = col_type.multiselect ? "in" : "="
        return HeaderFilterConfig("list", filter_func, "Select...", values, col_type.multiselect)
    else
        return HeaderFilterConfig("input", "regex", "Regex search...")
    end
end

function create_header_filter_config(col_type::ColumnHeatmap, table, colname)::HeaderFilterConfig
    # No filter for heatmap columns
    return HeaderFilterConfig("", "", "", nothing, false)
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
        return """function(cell) {
          var val = cell.getValue();
          if (val == null || val === '') return '';
          if (typeof val === 'string') return val;  // NaN, Infinity, -Infinity
          return val.toFixed($dp);
        }"""
    else
        # Get column data to determine element type
        cols = Tables.columns(table)
        col_data = Tables.getcolumn(cols, colname)
        eltype_col = eltype(col_data)

        # Check if the column contains floating point numbers
        # This includes Union{Missing, Float64}, Union{Nothing, Float64}, etc.
        has_float = any(col_data) do val
            !ismissing(val) && val !== nothing && val isa AbstractFloat
        end

        if has_float || eltype_col <: AbstractFloat
            # Use toFixed for floating point to ensure period decimal separator
            return """function(cell) {
              var val = cell.getValue();
              if (val == null || val === '') return '';
              if (typeof val === 'string') return val;  // NaN, Infinity, -Infinity
              if (typeof val === 'number') {
                // Use toFixed to ensure period decimal separator regardless of locale
                return val.toFixed(2);
              }
              return val;
            }"""
        else
            # For integers, just convert to string (no decimal point needed)
            return """function(cell) {
              var val = cell.getValue();
              if (val == null || val === '') return '';
              if (typeof val === 'string') return val;  // NaN, Infinity, -Infinity
              return String(val);
            }"""
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

function create_formatter(col_type::ColumnHeatmap, table, colname)
    # Get column data to compute min/max if needed
    cols = Tables.columns(table)
    col_data = Tables.getcolumn(cols, colname)

    # Filter to only valid numeric values for min/max calculation
    valid_values = filter(col_data) do val
        !ismissing(val) && val !== nothing && val isa Number && isfinite(val)
    end

    # Determine min and max values
    min_val = if isnothing(col_type.min_value)
        isempty(valid_values) ? 0.0 : minimum(valid_values)
    else
        col_type.min_value
    end

    max_val = if isnothing(col_type.max_value)
        isempty(valid_values) ? 1.0 : maximum(valid_values)
    else
        col_type.max_value
    end

    # Handle edge case where min == max
    if min_val == max_val
        max_val = min_val + 1.0
    end

    # Create JavaScript array of viridis colors
    palette_js = "[" * join(["'$c'" for c in col_type.palette], ", ") * "]"

    # Generate JavaScript formatter function
    return """function(cell) {
      var val = cell.getValue();

      // Handle null/missing/nothing - white background
      if (val == null || val === '') {
        var cellElement = cell.getElement();
        cellElement.style.backgroundColor = '#ffffff';
        cellElement.style.color = '#000000';
        return '';
      }

      // Handle NaN/Infinity/-Infinity - gray background
      if (typeof val === 'string') {
        var cellElement = cell.getElement();
        cellElement.style.backgroundColor = '#d3d3d3';
        cellElement.style.color = '#000000';
        return '';
      }

      // Viridis color palette
      var palette = $palette_js;
      var minVal = $min_val;
      var maxVal = $max_val;

      // Normalize value to [0, 1] range
      var normalized = (val - minVal) / (maxVal - minVal);
      normalized = Math.max(0, Math.min(1, normalized));  // Clamp to [0, 1]

      // Map to palette index
      var paletteIndex = Math.floor(normalized * (palette.length - 1));
      var color = palette[paletteIndex];

      // Calculate contrasting text color (white for dark, black for light backgrounds)
      var r = parseInt(color.substr(1,2), 16);
      var g = parseInt(color.substr(3,2), 16);
      var b = parseInt(color.substr(5,2), 16);
      var brightness = (r * 299 + g * 587 + b * 114) / 1000;
      var textColor = brightness > 155 ? '#000000' : '#ffffff';

      // Apply styling to the entire cell
      var cellElement = cell.getElement();
      cellElement.style.backgroundColor = color;
      cellElement.style.color = textColor;

      // Return empty string - no text displayed, only color
      return '';
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
get_alignment(col_type::ColumnHeatmap) = string(col_type.alignment)

"""
    create_column_config(table, colname, col_type::ColumnType)

Create complete column configuration for a specific column type.
"""
function create_column_config(table, colname, col_type::ColumnType)
    colname_str = String(colname)

    config = Dict{String, Any}(
        "title" => colname_str,
        "field" => colname_str,
        "headerSort" => true,
        "headerTooltip" => colname_str,
        "tooltip" => true  # Show raw cell value as tooltip
    )

    # Add title formatter with dynamic sort arrow for ALL column types
    if col_type isa ColumnHeatmap
        # Heatmap columns: rotated header with inline arrow
        # Note: margin-top and margin-left are set dynamically via CSS in table_html.jl
        config["titleFormatter"] = """function(cell) {
          var value = cell.getValue();
          return '<span class="rotated-header"><span class="sort-arrow">○</span> ' + value + '</span>';
        }"""
    else
        # Regular columns: normal header with inline arrow
        config["titleFormatter"] = """function(cell) {
          var value = cell.getValue();
          return '<span class="sort-arrow">○</span> ' + value;
        }"""
    end

    # Special handling for ColumnHeatmap
    if col_type isa ColumnHeatmap
        # Set fixed width to match row height (creating square cells)
        config["width"] = 25
        config["minWidth"] = 25
        config["maxWidth"] = 25
        config["resizable"] = false

        # Add CSS class to identify heatmap columns
        config["cssClass"] = "heatmap-column"

        # Skip filter configuration for heatmap columns
    else
        # Add header filter configuration for non-heatmap columns
        filter_config = create_header_filter_config(col_type, table, colname)
        config["headerFilter"] = filter_config.filter_type
        config["headerFilterFunc"] = filter_config.filter_func
        config["headerFilterPlaceholder"] = filter_config.placeholder

        # Add dropdown values if present
        if !isnothing(filter_config.values)
            params = Dict{String, Any}("values" => filter_config.values)
            # Add multiselect if enabled
            if filter_config.multiselect
                params["multiselect"] = true
            end
            config["headerFilterParams"] = params
        end
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

    return config
end

"""
    auto_detect_column_type(table, colname; auto_categorical_threshold=length(DEFAULT_CATEGORICAL_PALETTE))

Automatically detect the best column type for a column based on its data type and values.
Handles missing, NaN, and empty values robustly.
"""
function auto_detect_column_type(table, colname; auto_categorical_threshold=nothing)
    auto_categorical_threshold = isnothing(auto_categorical_threshold) ? length(DEFAULT_CATEGORICAL_PALETTE) : auto_categorical_threshold
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
