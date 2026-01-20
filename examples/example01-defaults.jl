using TableExplorer
using DataFrames

df = DataFrame(
    id = 1:100,
    status = rand(["Active", "Inactive", "Pending"], 100),
    priority = rand(["High", "Medium", "Low"], 100),
    region = rand(["North", "South", "East", "West"], 100),
    value = rand(100) .* 1000
)

explore_table(df; auto_categorical_threshold=3)
