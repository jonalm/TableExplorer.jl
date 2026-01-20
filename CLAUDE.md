# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TableExplorer.jl is a Julia package that generates standalone interactive HTML tables from any Tables.jl-compatible data structure (DataFrames, CSV files, Arrow tables, etc.). It uses Tabulator.js to provide sorting, filtering, column customization, and export capabilities.

### Dependencies

Core dependencies:
- **Tables.jl**: Table interface for universal compatibility
- **JSON.jl**: Data serialization
- **ColorSchemes.jl**: Color palette generation (batlowWS scheme)
- **Colors.jl**: Hex color conversion
- **Dates.jl**: Date/time handling

Test dependencies:
- **Test.jl**: Standard testing framework
- **DataFrames.jl**: Example data structures
- **StableRNGs.jl**: Reproducible random number generation for tests
- **Random.jl**: Random data generation

## Development Commands

### Running Examples
```bash
julia --project=. examples/example01-defaults.jl
julia --project=. examples/example02-custom-colors.jl
```

### Running Tests
```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

### Starting Julia REPL with Project
```bash
julia --project=.
```

### Package Management
```bash
# Instantiate dependencies
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Update dependencies
julia --project=. -e 'using Pkg; Pkg.update()'
```

## Architecture

### Module Structure

The package is organized into four main source files, each with a corresponding test file:
- [src/column_types.jl](src/column_types.jl) → [test/test_column_types.jl](test/test_column_types.jl)
- [src/table_html.jl](src/table_html.jl) → [test/test_table_html.jl](test/test_table_html.jl)
- [src/utils.jl](src/utils.jl) → [test/test_utils.jl](test/test_utils.jl)
- [src/api.jl](src/api.jl) → [test/test_api.jl](test/test_api.jl)

### Exports

The package exports the following public API:
- `explore_table`: Main function to generate and view tables
- `ColumnBoolean`, `ColumnCategorical`, `ColumnDateTime`, `ColumnNumeric`, `ColumnText`: Column type constructors

Note: `table_html` is NOT exported and is considered internal, though it can be called directly if needed.

### Core Components

1. **Column Type System** ([src/column_types.jl](src/column_types.jl))
   - Abstract `ColumnType` base type with concrete implementations:
     - `ColumnText`: Regex/exact/contains filtering
     - `ColumnNumeric`: Decimal formatting and alignment control
     - `ColumnCategorical`: Auto-colored cells based on unique values
     - `ColumnDateTime`: Date formatting
     - `ColumnBoolean`: Custom labels for true/false
   - Each type defines three behaviors via functions:
     - `create_header_filter_config()`: Tabulator filter configuration
     - `create_formatter()`: JavaScript formatter function for cell rendering
     - `get_alignment()`: Text alignment (left/right/center)
   - Auto-detection logic (`auto_detect_column_type()`) inspects column data to choose appropriate type

2. **HTML Generation Pipeline** ([src/table_html.jl](src/table_html.jl))
   - `table_html()`: Main function that orchestrates HTML generation
   - Converts Tables.jl interface to JSON data structure
   - Generates Tabulator.js column configurations
   - Embeds static resources (CSS/JS/HTML template) into standalone file
   - Special handling: `config_to_json()` preserves JavaScript function literals in JSON

3. **Utilities** ([src/utils.jl](src/utils.jl))
   - `DEFAULT_CATEGORICAL_PALETTE`: 15-color palette from ColorSchemes.batlowWS
   - `generate_categorical_colors()`: Deterministic color assignment (sorts values alphabetically)
   - `assign_color_to_value()`: Helper for mapping individual values to palette colors
   - `create_categorical_formatter()`: JavaScript formatter with automatic text contrast
   - `js_string_literal()`: Escapes strings for safe embedding in JavaScript
   - `row_to_dict()`: Converts table rows to dictionaries, handling NaN/Inf as `nothing`
   - `open_in_browser()`: Cross-platform browser launching (macOS, Windows, Linux)

4. **Public API** ([src/api.jl](src/api.jl))
   - `explore_table()`: Wrapper that generates HTML and opens in browser
   - Creates temporary file in `mktempdir()` and launches system browser

### Data Flow

```
Tables.jl table → table_html() → Column type detection/assignment →
Tabulator configs + JSON data → Template substitution → HTML string →
explore_table() → Temp file → Browser
```

### Static Resources

- [src/tableexplorer_template.html](src/tableexplorer_template.html): HTML skeleton with placeholders
- [src/tableexplorer.css](src/tableexplorer.css): Styling
- [src/tableexplorer.js](src/tableexplorer.js): Tabulator initialization and event handling

These files are embedded directly into the generated HTML for standalone distribution.

## Key Design Patterns

### Column Type Configuration
Column types use keyword arguments with defaults (`Base.@kwdef struct`) to allow partial customization:
```julia
ColumnNumeric(decimal_places=2)  # Uses default alignment=:right
```

### Dual Key Support
Column specifications accept both `String` and `Symbol` keys, normalized to `Symbol` internally:
```julia
explore_table(df,
    "status" => ColumnCategorical(),  # String key
    :price => ColumnNumeric()         # Symbol key
)
```

### Auto-Detection with Override
The `auto_categorical_threshold` parameter enables smart defaults while allowing explicit control:
- Columns with explicit types use those types
- Other string columns become `ColumnCategorical` if unique values ≤ threshold
- Set to `nothing` to disable auto-detection entirely

### JavaScript Function Serialization
`config_to_json()` detects JavaScript function strings and embeds them unquoted in the JSON output, enabling Tabulator formatters to work correctly.


## Code style

- Prefer functional patterns as `map`/`filter`/`mapreduce`/`foreach` etc. over
  imperative `for`/`while` loops. Exceptions are acceptable if it makes code
  clearer.
- Adhere to the "single-responsibility principle". Try to structure the code
  into small independent functions, and break larger functions into smaller ones
  that can be tested independently.
- For each src/*.jl file, there should be a corresponding unit test file
  `test/test_*.jl` which covers the functionality. All tests should be referenced by `test/runtests.jl`

## Documentation

Main user documentation, which includes examples, should be in the doc string
associated with `explore_table` function, and the `ColumnX` Column type object.

All other function should only have a concise docstring.


## Miscellaneous

- The functionality must support `Missing` and/or `Nothing` values in the columns, as they are common in real world data.
- For floating point numerical columns, the functionality must also support `NaN`, `Inf` and `-Inf`. 