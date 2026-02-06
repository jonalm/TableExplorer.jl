using TableExplorer
using DataFrames

# Create example data
df = DataFrame(
    status = rand(["Active", "Inactive", "Pending", "Archived"], 50),
    priority = rand(["High", "Medium", "Low"], 50),
    department = rand(["Engineering", "Sales", "Marketing", "HR"], 50),
    score = rand(50) .* 100,
    is_complete = rand(Bool, 50),
    verified = rand(Bool, 50)
)

# Demonstrate multiselect on categorical and boolean columns
# - status and priority use multiselect (can select multiple values at once)
# - department uses single select (default)
# - is_complete uses multiselect (can show both true and false, or just one)
# - verified uses single select (default for booleans)
explore_table(df,
    :status => ColumnCategorical(multiselect=true),
    :priority => ColumnCategorical(multiselect=true),
    :department => ColumnCategorical(),  # Single select for comparison
    :score => ColumnNumeric(decimal_places=2),
)
