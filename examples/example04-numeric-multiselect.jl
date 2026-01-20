using TableExplorer
using DataFrames

# Create a DataFrame with various numeric value types
df = DataFrame(
    id = 1:20,
    measurement = [
        # Normal numerical values
        1.5, 2.3, 3.7, 4.2, 5.8,
        # NaN values
        NaN, NaN,
        # Infinity values
        Inf, Inf, -Inf,
        # Missing/Nothing values
        missing, nothing, missing,
        # More normal values
        6.1, 7.9, 8.4, 9.2, 10.5, 11.3, 12.7
    ],
    category = repeat(["A", "B", "C", "D"], 5)
)

# Display the table with numeric multiselect dropdown filter
# The dropdown will show options for: numerical, NaN, Infinity, -Infinity, (null)
# Users can select multiple value types to filter by
explore_table(df,
    :measurement => ColumnNumeric(
        search_type=:dropdown,
        decimal_places=2,
        multiselect=true  # Default, allows selecting multiple types
    ),
    :category => ColumnCategorical()
)

# Note: In the browser, try selecting different combinations:
# - Only "numerical" to see valid numbers
# - Only "NaN" to see NaN values
# - "Infinity" and "-Infinity" to see infinite values
# - "(null)" to see missing/nothing values
# - Multiple selections to see combined results
