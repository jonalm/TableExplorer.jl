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
    "status" => CategoricalColumn(
        color_map=Dict(
            "Pass" => "#28a745",     # Green
            "Fail" => "#dc3545",     # Red
            "Warning" => "#ffc107"   # Yellow
        )
    ),
    :score => NumericColumn(decimal_places=3),
    "severity" => TextColumn(),
    :boolean => BooleanColumn()
)
 