using TableExplorer
using DataFrames

N = 100
df = DataFrame(
    status = rand(["Pass", "Fail", "Warning", missing, nothing], N),
    severity = rand(["Critical", "High", "Medium", "Low", missing, nothing], N),
    score = rand(N) .* 100,
    boolean_1 = rand(Bool, N),
    boolean_2 = rand(Bool, N),
)
df.score[ randn(N) .> 1.0 ] .= NaN
df.score_with_missing = [randn()>2 ? missing : x for x in df.score ]

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
    :boolean1 => ColumnCategorical()
)
 

