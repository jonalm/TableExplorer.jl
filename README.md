# TableExplorer.jl


## API

### Main entrypoint

`TableExplorer.jl` exports one main function `explore_table(df)`, which takes a
`df` table input conforming to the
[`Table.jl`](https://tables.juliadata.org/stable/) interface. It creates a
standalone HTML file and opens this file in your default browser.

### Custom Column view

You can customize how the columns are displayed by associating column names to `ColumX` objects. The available `ColumX` objects are:

- `ColumnBoolean`
- `ColumnCategorical`
- `ColumnDateTime`
- `ColumnNumeric`
- `ColumnText`

```julia
using TableExplorer
using DataFrames

df = DataFrame(
    status = rand(["Pass", "Fail", "Warning"], 50),
    severity = rand(["Critical", "High", "Medium", "Low"], 50),
    score = rand(50) .* 100,
    boolean = rand(Bool, 50),
    default_boolean = rand(Bool, 50),
)

explore_table(df,
    "status" => ColumnCategorical(
        color_map=Dict(
            "Pass" => "#28a745",     # Green
            "Fail" => "#dc3545",     # Red
            "Warning" => "#ffc107"   # Yellow
        )
    ),
    :score => ColumnNumeric(decimal_places=3),
    "severity" => ColumnText(),
    :boolean => ColumnBoolean()
)
```