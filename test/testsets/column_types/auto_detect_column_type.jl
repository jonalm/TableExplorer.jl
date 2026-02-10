using Test
using TableExplorer
using DataFrames

# Test numeric detection
df_num = DataFrame(value = [1.5, 2.5, 3.5])
result = TableExplorer.auto_detect_column_type(df_num, :value)
@test result isa ColumnNumeric

# Test integer detection
df_int = DataFrame(count = [1, 2, 3])
result = TableExplorer.auto_detect_column_type(df_int, :count)
@test result isa ColumnNumeric


# Test categorical detection (few unique values)
df_cat = DataFrame(status = ["A", "B", "A", "C", "B"])
result = TableExplorer.auto_detect_column_type(df_cat, :status, auto_categorical_threshold=5)
@test result isa ColumnCategorical

# Test text detection (many unique values)
df_text = DataFrame(id = string.(1:20))
result = TableExplorer.auto_detect_column_type(df_text, :id, auto_categorical_threshold=10)
@test result isa ColumnText

# Test with missing values
df_missing = DataFrame(value = [1, missing, 3])
result = TableExplorer.auto_detect_column_type(df_missing, :value)
@test result isa ColumnNumeric

# Test with Nothing type
df_nothing = DataFrame(value = [nothing, nothing])
result = TableExplorer.auto_detect_column_type(df_nothing, :value)
@test result isa ColumnText

# Test categorical with empty strings
df_empty = DataFrame(status = ["A", "", "B", "", "C"])
result = TableExplorer.auto_detect_column_type(df_empty, :status, auto_categorical_threshold=5)
@test result isa ColumnCategorical
