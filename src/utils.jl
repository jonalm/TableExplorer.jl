
_prepend(x,y) = x*y
_prepend(x) = Base.Fix1(_prepend, x)
const DEFAULT_CATEGORICAL_PALETTE = map(_prepend("#") ∘ hex, ColorSchemes.Pastel2_8)
const CONTINUOUS_PALETTE = map(_prepend("#") ∘ hex, ColorSchemes.lipari100)


"""
    assign_color_to_value(indexed_value, palette)

Assign a color to a single indexed value from the palette.

# Arguments
- `indexed_value`: Tuple of (index, value)
- `palette`: Color palette vector

# Returns
Pair of string(value) => color
"""
function assign_color_to_value(indexed_value, palette)
    i, value = indexed_value
    color_idx = mod1(i, length(palette))
    return string(value) => palette[color_idx]
end

"""
    generate_categorical_colors(unique_values; palette=DEFAULT_CATEGORICAL_PALETTE)

Generate deterministic color mapping for categorical values.
Values are sorted alphabetically to ensure consistent color assignment across sessions.
Special values (missing, nothing) are sorted to the end.

# Arguments
- `unique_values`: Collection of unique values to assign colors
- `palette`: Color palette to use (cycles if more values than colors)

# Returns
Dictionary mapping string values to hex colors
"""
function generate_categorical_colors(unique_values, palette=DEFAULT_CATEGORICAL_PALETTE)
    vals = collect(unique_values)

    # Separate normal values from special values (missing/nothing) for sorting
    normal_vals = filter(v -> !ismissing(v) && v !== nothing, vals)
    special_vals = filter(v -> ismissing(v) || v === nothing, vals)

    # Sort normal values and append special values at the end
    sorted_values = vcat(sort(normal_vals), special_vals)

    pairs = map(Base.Fix2(assign_color_to_value, palette), enumerate(sorted_values))
    return Dict{String, String}(pairs)
end

"""
    js_string_literal(s::String)

Escape a Julia string for safe embedding in JavaScript string literals.

Handles common escape sequences:
- Single quotes (') → \\'
- Backslashes (\\) → \\\\
- Newlines (\\n) → \\\\n
- Carriage returns (\\r) → \\\\r

# Arguments
- `s`: String to escape

# Returns
Escaped string ready for embedding in JavaScript code (without surrounding quotes)

# Examples
```julia
js_string_literal("It's true")  # Returns: "It\\'s true"
js_string_literal("Line 1\\nLine 2")  # Returns: "Line 1\\\\nLine 2"
```
"""
function js_string_literal(s::String)
    # Order matters: escape backslashes first to avoid double-escaping
    escaped = replace(s,
        "\\" => "\\\\",
        "'" => "\\'",
        "\n" => "\\n",
        "\r" => "\\r"
    )
    return escaped
end

function open_in_browser(path)
    @static if Sys.isapple()
        run(`open $path`)
    elseif Sys.iswindows()
        run(`cmd /c start "" $path`)
    elseif Sys.islinux()
        run(`xdg-open $path`)
    else
        @warn "Unsupported platform. Please open the file manually: $path"
    end
end


"""
    row_to_dict(row, colnames)

Convert a single table row to a dictionary with string keys, handling special numeric values.

# Arguments
- `row`: A single row from a Tables.jl-compatible table
- `colnames`: Collection of column names for the row

# Returns
Dictionary mapping column names (as strings) to values, with special handling:
- NaN → "NaN" (string)
- Inf → "Infinity" (string)
- -Inf → "-Infinity" (string)
- missing/nothing → nothing (becomes JSON null)
"""
function row_to_dict(row, colnames)
    Dict{String, Any}(
        String(colname) => let val = Tables.getcolumn(row, colname)
            if val isa AbstractFloat
                if isnan(val)
                    "NaN"
                elseif isinf(val)
                    val > 0 ? "Infinity" : "-Infinity"
                else
                    val
                end
            else
                val
            end
        end
        for colname in colnames
    )
end


"""
    create_categorical_formatter(color_map::Dict{String, String})

Generate JavaScript formatter function for Tabulator.js that colors entire cells.

The formatter applies cell-level styling with:
- Background color from color_map
- Automatic text color contrast (white/black based on background brightness)
- Default light gray for unmapped values

# Arguments
- `color_map`: Dictionary mapping category values to hex colors

# Returns
JavaScript function string compatible with Tabulator.js formatter API
"""
function create_categorical_formatter(color_map::Dict{String, String})
    # Convert color map to JavaScript object literal with proper escaping
    color_entries = ["    '$(js_string_literal(k))': '$(v)'" for (k, v) in color_map]
    color_obj = "{\n" * join(color_entries, ",\n") * "\n  }"

    # Generate JavaScript formatter function with cell-level styling
    formatter = """function(cell) {
      var val = cell.getValue();
      if (val == null || val === '') return '';

      var colorMap = $(color_obj);
      var color = colorMap[val] || '#f0f0f0';  // Default light gray for unmapped values

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
      cellElement.style.fontWeight = '500';

      return val;
    }"""

    return formatter
end
