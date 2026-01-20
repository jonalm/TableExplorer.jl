# TableExplorer.jl

TableExplorer.jl is a Julia package that generates standalone interactive HTML tables from any Tables.jl-compatible data structure (DataFrames, CSV files, Arrow tables, etc.). It uses [Tabulator.js](http://tabulator.info/) to provide sorting, filtering, column customization, and export capabilities.

## Features

- **Universal Table Support**: Works with any Tables.jl-compatible data structure
- **Interactive Viewing**: Generates standalone HTML files that open in your default browser
- **Smart Type Detection**: Automatically detects column types (numeric, categorical, boolean, text)
- **Customizable Display**: Override automatic detection with explicit column type specifications
- **Sorting & Filtering**: Built-in header filters for all columns
- **Color-Coded Categories**: Automatic or custom color mapping for categorical columns
- **Missing Data Handling**: Robust support for `Missing`, `Nothing`, `NaN`, `Inf`, and `-Inf` values

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/jonalm/TableExplorer.jl")
```

## Quick Start

```julia
using TableExplorer
using DataFrames

df = DataFrame(
    id = 1:100,
    status = rand(["Active", "Inactive", "Pending"], 100),
    priority = rand(["High", "Medium", "Low"], 100),
    value = rand(100) .* 1000
)

# Open interactive table in browser
explore_table(df)
```

## API

### Main Function

```julia
explore_table(table, column_types::Pair...; auto_categorical_threshold=10)
```

Opens an interactive HTML table view in your default browser.

**Arguments:**
- `table`: Any Tables.jl-compatible table (DataFrame, NamedTuple of vectors, etc.)
- `column_types`: Variable number of `column_name => ColumnType` pairs (column names can be String or Symbol)

**Keyword Arguments:**
- `auto_categorical_threshold::Union{Int, Nothing}`: Maximum unique values for automatic categorical detection (default: 10). Set to `nothing` to disable auto-detection.

### Column Types

Override automatic type detection by specifying column types explicitly:

#### `ColumnText`
For text data with regex/exact/contains filtering.

```julia
ColumnText(; search_type=:regex)  # :regex, :exact, or :contains
```

#### `ColumnNumeric`
For numeric data with custom formatting and alignment.

```julia
ColumnNumeric(;
    decimal_places=nothing,  # Number of decimals (nothing = auto)
    alignment=:right,        # :left, :right, or :center
    search_type=:input      # :input or :range
)
```

#### `ColumnCategorical`
For categorical data with automatic or custom color coding.

```julia
ColumnCategorical(;
    color_map=nothing,      # Dict("value" => "#hexcolor") or nothing for auto
    search_type=:input,     # :input, :dropdown, or :exact
    show_colors=true,       # Whether to apply background colors
    palette=DEFAULT_CATEGORICAL_PALETTE  # Color palette for auto-generation
)
```

#### `ColumnDateTime`
For date/time data with custom formatting.

```julia
ColumnDateTime(;
    format="yyyy-mm-dd HH:MM:SS",
    search_type=:input      # :input or :range
)
```

#### `ColumnBoolean`
For boolean data with custom labels.

```julia
ColumnBoolean(;
    search_type=:dropdown,   # :dropdown, :exact, or :input
    true_label="✓",
    false_label="✗"
)
```

## Examples

### Basic Usage with Auto-Detection

```julia
using TableExplorer
using DataFrames

df = DataFrame(
    id = 1:100,
    status = rand(["Active", "Inactive", "Pending"], 100),
    priority = rand(["High", "Medium", "Low"], 100),
    region = rand(["North", "South", "East", "West"], 100),
    value = rand(100) .* 1000
)

# All string columns with ≤10 unique values become categorical
explore_table(df)
```

### Custom Column Types

```julia
df = DataFrame(
    status = rand(["Pass", "Fail", "Warning"], 50),
    severity = rand(["Critical", "High", "Medium", "Low"], 50),
    score = rand(50) .* 100,
    is_active = rand(Bool, 50),
    flag = rand(Bool, 50)
)

explore_table(df,
    "status" => ColumnCategorical(
        color_map=Dict(
            "Pass" => "#28a745",     # Green
            "Fail" => "#dc3545",     # Red
            "Warning" => "#ffc107"   # Yellow
        )
    ),
    :score => ColumnNumeric(decimal_places=2),
    "severity" => ColumnText(search_type=:contains),
    :is_active => ColumnBoolean(true_label="Yes", false_label="No")
)
```

### Mixed Auto and Manual Configuration

```julia
# Manually configure some columns, auto-detect others
explore_table(df,
    :status => ColumnCategorical(color_map=my_colors),
    :score => ColumnNumeric(decimal_places=2),
    auto_categorical_threshold=15  # Increase threshold for other columns
)
```

## How It Works

1. **Column Type Detection**: Analyzes each column's data type and values
2. **Configuration Generation**: Creates Tabulator.js column configurations
3. **Data Serialization**: Converts table data to JSON, handling special values
4. **HTML Generation**: Embeds data, config, and static resources into standalone HTML
5. **Browser Launch**: Opens the HTML file using platform-specific commands

## Development

See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation and development guidelines.